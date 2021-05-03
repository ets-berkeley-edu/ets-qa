require_relative '../../util/spec_helper'

include Logging

test = BOACTestConfig.new
test.degree_progress
template = test.degree_templates.find { |t| t.name.include? BOACUtils.degree_major.first }

describe 'A BOA degree check' do

  before(:all) do
    @driver = Utils.launch_browser
    @homepage = BOACHomePage.new @driver
    @pax_manifest = BOACPaxManifestPage.new @driver
    @degree_templates_mgmt_page = BOACDegreeCheckMgmtPage.new @driver
    @degree_template_page = BOACDegreeCheckTemplatePage.new @driver
    @student_page = BOACStudentPage.new @driver
    @student_api_page = BOACApiStudentPage.new @driver
    @degree_check_create_page = BOACDegreeCheckCreatePage.new @driver
    @degree_check_page = BOACDegreeCheckPage.new @driver

    unless test.advisor.degree_progress_perm == DegreeProgressPerm::WRITE && test.read_only_advisor.degree_progress_perm == DegreeProgressPerm::READ
      @homepage.dev_auth
      @pax_manifest.load_page
      @pax_manifest.set_deg_prog_perm(test.advisor, BOACDepartments::COE, DegreeProgressPerm::WRITE)
      @pax_manifest.set_deg_prog_perm(test.read_only_advisor, BOACDepartments::COE, DegreeProgressPerm::READ)
      @pax_manifest.log_out
    end

    @homepage.dev_auth test.advisor
    @homepage.click_degree_checks_link
    @degree_templates_mgmt_page.create_new_degree template
    @degree_template_page.complete_template template

    @student = ENV['UIDS'] ? (test.students.find { |s| s.uid == ENV['UIDS'] }) : test.cohort_members.shuffle.first
    @degree_check = DegreeProgressChecklist.new(template, @student)
    @student_api_page.get_data(@driver, @student)
    @unassigned_courses = @student_api_page.degree_progress_courses

    @student_page.load_page @student
  end

  after(:all) { Utils.quit_browser @driver }

  context 'when created' do

    it 'can be selected from a list of degree check templates' do
      @degree_check_create_page.load_page @student
      @degree_check_create_page.select_template template
    end

    it 'can be canceled' do
      @degree_check_create_page.click_cancel_degree
      @student_page.toggle_personal_details_element.when_visible Utils.short_wait
    end

    it 'can be created' do
      @degree_check_create_page.load_page @student
      @degree_check_create_page.create_new_degree_check(@degree_check)
    end

    template.unit_reqts&.each do |u_req|
      it "shows units requirement #{u_req.name} name" do
        @degree_check_page.wait_until(1, "Expected #{u_req.name}, got #{@degree_check_page.visible_unit_req_name u_req}") do
          @degree_check_page.visible_unit_req_name(u_req) == u_req.name
        end
      end

      it "shows units requirement #{u_req.name} unit count #{u_req.unit_count}" do
        @degree_check_page.wait_until(1, "Expected #{u_req.unit_count}, got #{@degree_check_page.visible_unit_req_num u_req}") do
          @degree_check_page.visible_unit_req_num(u_req) == u_req.unit_count
        end
      end
    end

    template.categories&.each do |cat|
      it "shows category #{cat.id} name #{cat.name}" do
        @degree_check_page.wait_until(1, "Expected #{cat.name}, got #{@degree_check_page.visible_cat_name cat}") do
          @degree_check_page.visible_cat_name(cat) == cat.name
        end
      end

      it "shows category #{cat.name} description #{cat.desc}" do
        if cat.desc && !cat.desc.empty?
          @degree_check_page.wait_until(1, "Expected #{cat.desc}, got #{@degree_check_page.visible_cat_desc cat}") do
            "#{@degree_check_page.visible_cat_desc(cat)}" == "#{cat.desc}"
          end
        end
      end

      cat.sub_categories&.each do |sub_cat|
        it "shows subcategory #{sub_cat.name} name" do
          @degree_check_page.wait_until(1, "Expected #{sub_cat.name}, got #{@degree_check_page.visible_cat_name(sub_cat)}") do
            @degree_check_page.visible_cat_name(sub_cat) == sub_cat.name
          end
        end

        it "shows subcategory #{sub_cat.name} description #{sub_cat.desc}" do
          @degree_check_page.wait_until(1, "Expected #{sub_cat.desc}, got #{@degree_check_page.visible_cat_desc(sub_cat)}") do
            @degree_check_page.visible_cat_desc(sub_cat) == sub_cat.desc
          end
        end

        sub_cat.course_reqs&.each do |course|
          it "shows subcategory #{sub_cat.name} course #{course.name} name" do
            @degree_check_page.wait_until(1, "Expected #{course.name}, got #{@degree_check_page.visible_course_req_name course}") do
              @degree_check_page.visible_course_req_name(course) == course.name
            end
          end

          it "shows subcategory #{sub_cat.name} course #{course.name} units #{course.units}" do
            @degree_check_page.wait_until(1, "Expected #{course.units}, got #{@degree_check_page.visible_course_req_units course}") do
              course.units ? (@degree_check_page.visible_course_req_units(course) == course.units) : (@degree_check_page.visible_course_req_units(course) == '—')
            end
          end

          it "shows subcategory #{sub_cat.name} course #{course.name} units requirements #{course.units_reqts}" do
            if course.units_reqts&.any?
              course.units_reqts.each do |u_req|
                @degree_check_page.wait_until(1, "Expected #{u_req.name}, got #{@degree_check_page.visible_course_req_fulfillment course}") do
                  @degree_check_page.visible_course_req_fulfillment(course).include? u_req.name
                end
              end
            else
              @degree_check_page.wait_until(1, "Expected —, got #{@degree_check_page.visible_course_req_fulfillment course}") do
                @degree_check_page.visible_course_req_fulfillment(course) == '—'
              end
            end
          end
        end
      end

      cat.course_reqs&.each do |course|
        it "shows category #{cat.name} course #{course.name} name" do
          @degree_check_page.wait_until(1, "Expected #{course.name}, got #{@degree_check_page.visible_course_req_name course}") do
            @degree_check_page.visible_course_req_name(course) == course.name
          end
        end

        it "shows category #{cat.name} course #{course.name} units #{course.units}" do
          @degree_check_page.wait_until(1, "Expected #{course.units}, got #{@degree_check_page.visible_course_req_units course}") do
            course.units ? (@degree_check_page.visible_course_req_units(course) == course.units) : (@degree_check_page.visible_course_req_units(course) == '—')
          end
        end

        it "shows category #{cat.name} course #{course.name} units requirements #{course.units_reqts}" do
          if course.units_reqts&.any?
            course.units_reqts.each do |u_req|
              @degree_check_page.wait_until(1, "Expected #{u_req.name}, got #{@degree_check_page.visible_course_req_fulfillment course}") do
                @degree_check_page.visible_course_req_fulfillment(course).include? u_req.name
              end
            end
          else
            @degree_check_page.wait_until(1, "Expected —, got #{@degree_check_page.visible_course_req_fulfillment course}") do
              @degree_check_page.visible_course_req_fulfillment(course) == '—'
            end
          end
        end
      end
    end
  end

  context 'note section' do

    before(:all) { @note_str = "Teena wuz here #{test.id} " * 10 }

    it('shows a no-notes message if no note exists') { expect(@degree_check_page.no_notes_msg.strip).to eql('There currently are no degree notes for this student.') }
    it('offers a create button for a note') { @degree_check_page.click_create_or_edit_note }
    it('allows the user to cancel a note') { @degree_check_page.click_cancel_note }
    it('allows the user to save a note') { @degree_check_page.create_or_edit_note @note_str }
    it('shows the note content') { expect(@degree_check_page.visible_note_body).to eql(@note_str.strip) }
    it('shows the note creating advisor') { expect(@degree_check_page.note_update_advisor).not_to be_empty }
    it('shows the note creation date') { expect(@degree_check_page.note_update_date).to eql(Date.today.strftime('%b %-d, %Y')) }
    it('offers an edit button for a note') { @degree_check_page.click_create_or_edit_note }
    it('allows the user to cancel a note edit') { @degree_check_page.click_cancel_note }
    it('allows the user to save a note edit') { @degree_check_page.create_or_edit_note("EDITED - #{@note_str}") }
    it('shows the edited note content') { expect(@degree_check_page.visible_note_body).to eql("EDITED - #{@note_str}".strip) }
    it('shows the note edit advisor') { expect(@degree_check_page.note_update_advisor).not_to be_empty }
    it('shows the note edit date') { expect(@degree_check_page.note_update_date).to eql(Date.today.strftime('%b %-d, %Y')) }
  end

  context 'unassigned courses' do

    it 'show the right courses' do
      expect(@degree_check_page.unassigned_course_ccns).to eql(@unassigned_courses.map { |c| "#{c.term_id}-#{c.ccn}" })
    end

    it 'show the right course name on each row' do
      @unassigned_courses.each do |course|
        logger.debug "Checking for #{course.name}"
        expect(@degree_check_page.unassigned_course_code(course)).to eql(course.name)
      end
    end

    it 'show the right course units on each row' do
      @unassigned_courses.each do |course|
        logger.debug "Checking for #{course.units}"
        expect(@degree_check_page.unassigned_course_units(course)).to eql(course.units)
      end
    end

    it 'show the right course grade on each row' do
      @unassigned_courses.each do |course|
        logger.debug "Checking for #{course.grade}"
        expect(@degree_check_page.unassigned_course_grade(course)).to eql(course.grade)
      end
    end

    it 'show the right course term on each row' do
      @unassigned_courses.each do |course|
        term = Utils.sis_code_to_term_name(course.term_id)
        logger.debug "Checking for #{term}"
        expect(@degree_check_page.unassigned_course_term(course)).to eql(term)
      end
    end

    context 'course' do

      before(:all) do
        cats_with_courses = @degree_check.categories.select { |cat| cat.course_reqs&.any? }
        @course_req_1 = cats_with_courses.first.course_reqs.first
        @course_req_2 = cats_with_courses.last.course_reqs.last
        @completed_course = @unassigned_courses.first
      end

      context 'edits' do

        it 'can be canceled' do
          @degree_check_page.click_edit_unassigned_course @completed_course
          @degree_check_page.click_cancel_unassigned_course_edit
        end

        it 'allows a user to add a note' do
          @completed_course.note = "Teena wuz here #{test.id}" * 10
          @degree_check_page.edit_unassigned_course @completed_course
          expect(@degree_check_page.unassigned_course_note @completed_course).to eql(@completed_course.note)
        end

        it 'allows a user to edit a note' do
          @completed_course.note = "EDITED - #{@completed_course.note}"
          @degree_check_page.edit_unassigned_course @completed_course
          expect(@degree_check_page.unassigned_course_note @completed_course).to eql(@completed_course.note)
        end

        # TODO it 'allows a user to remove a note' do
        #   @completed_course.note = ''
        #   @degree_check_page.edit_unassigned_course @completed_course
        #   expect(@degree_check_page.unassigned_course_note @completed_course).to eql(@completed_course.note)
        # end

        it 'allows a user to change units to another integer' do
          @completed_course.units = '6'
          @completed_course.note = 'foo' # TODO remove this
          @degree_check_page.edit_unassigned_course @completed_course
          expect(@degree_check_page.unassigned_course_units @completed_course).to eql(@completed_course.units)
        end

        # TODO it 'does not allow a user to change units to a non-integer'

        it 'does not allow a user to remove all units' do
          @degree_check_page.click_edit_unassigned_course @completed_course
          @degree_check_page.enter_unassigned_course_units ''
          expect(@degree_check_page.unassigned_course_update_button_element.enabled?).to be false
        end
      end

      context 'when assigned to a course requirement' do

        it 'updates the requirement row with the course name' do
          @degree_check_page.click_cancel_unassigned_course_edit
          @degree_check_page.assign_completed_course(@completed_course, @course_req_1)
        end

        it 'updates the requirement row with the course units' do
          expect(@degree_check_page.visible_course_req_units(@course_req_1)).to eql(@completed_course.units)
        end

        it 'removes the course from the unassigned courses list' do
          expect(@degree_check_page.unassigned_course_ccns).not_to include("#{@completed_course.term_id}-#{@completed_course.ccn}")
        end

        it 'prevents another course being assigned to the same requirement' do
          @degree_check_page.click_unassigned_course_select @unassigned_courses.last
          expect(@degree_check_page.unassigned_course_req_option(@unassigned_courses.last, @course_req_1).attribute('aria-disabled')).to eql('true')
        end

        # TODO it 'updates the requirement row with the course grade'
        # TODO it 'updates the requirement row with the course note'
        # TODO it 'shows the requirement row\'s pre-existing unit fulfillment(s)'

        context 'and edited' do

          it 'can be canceled' do
            @degree_check_page.click_edit_cat @course_req_1
            @degree_check_page.click_cancel_col_req
          end

          it 'allows a user to add a note'
          it 'allows a user to edit a note'
          it 'allows a user to remove a note'

          it 'allows a user to change units to another integer'
          it 'does not allow a user to change units to a non-integer'
          it 'does not allow a user to remove all units'
          # TODO it 'shows an indicator if the user has edited the course units'

          # TODO it 'allows the user to edit the course unit fulfillment(s)'
          # TODO it 'shows an indicator if the user has edited the course unit fulfillment(s)'
        end

      end

      context 'when unassigned from a course requirement' do

        it 'reverts the requirement row course name' do
          @degree_check_page.unassign_course(@completed_course, @course_req_1)
        end

        it 'reverts the requirement row course units' do
          if @course_req_1.units
            (@degree_template_page.visible_course_req_units(@course_req_1) == @course_req_1.units)
          else
            (@degree_template_page.visible_course_req_units(@course_req_1) == '—')
          end
        end

        # TODO it 'removes the requirement row course grade'
        # TODO it 'removes the requirement row course note'
        # TODO it 'reverts the requirement row course units'
        # TODO it 'reverts the requirement row unit fufillment(s)'

        it 'restores the course to the unassigned courses list' do
          expect(@degree_check_page.unassigned_course_row_el(@completed_course).exists?).to be true
        end
      end

      context 'when reassigned from one course requirement to another' do

        before(:all) { @degree_check_page.assign_completed_course(@completed_course, @course_req_1) }

        it 'updates the requirement row with the course name' do
          @degree_check_page.reassign_course(@completed_course, @course_req_1, @course_req_2)
        end

        it 'updates the requirement row with the course units' do
          expect(@degree_check_page.visible_course_req_units(@course_req_2)).to eql(@completed_course.units)
        end

        it 'removes the course from the unassigned courses list' do
          expect(@degree_check_page.unassigned_course_ccns).not_to include("#{@completed_course.term_id}-#{@completed_course.ccn}")
        end

        it 'prevents another course being assigned to the same requirement' do
          @degree_check_page.click_unassigned_course_select @unassigned_courses.last
          expect(@degree_check_page.unassigned_course_req_option(@unassigned_courses.last, @course_req_2).attribute('aria-disabled')).to eql('true')
        end
      end
    end
  end
end