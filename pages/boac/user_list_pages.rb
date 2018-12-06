require_relative '../../util/spec_helper'

module Page
  module BOACPages

    module UserListPages

      include PageObject
      include Logging
      include Page
      include BOACPages

      # Returns all the SIDs visible in a list. If a cohort is given, then returns the SIDs shown under that cohort.
      # @param driver [Selenium::WebDriver]
      # @param cohort [Cohort]
      def all_row_sids(driver, cohort = nil)
        # TODO - account for curated cohorts too
        xpath = filtered_cohort_xpath cohort if cohort && cohort.instance_of?(FilteredCohort)
        driver.find_elements(xpath: "#{xpath}//span[@data-ng-bind='student.sid']").map &:text
      end

      # Returns the XPath to a filtered cohort's div in the main content area on the homepage
      # @param cohort [FilteredCohort]
      # @return [String]
      def filtered_cohort_xpath(cohort)
        "//div[@id=\"content\"]//div[@data-ng-repeat=\"cohort in profile.myFilteredCohorts track by $index\"][contains(.,\"#{cohort.name}\")]"
      end

      # Returns the data visible for a user on the search results page or in a filtered or curated cohort on the homepage. If an XPath is included,
      # then returns rows under the associated filtered cohort or curated group.
      # @param driver [Selenium::WebDriver]
      # @param sid [String]
      # @param cohort_xpath [String]
      # @return [Hash]
      def user_row_data(driver, sid, cohort_xpath = nil)
        row_xpath = "#{cohort_xpath}//tr[contains(@data-ng-repeat,\"student in students\")][contains(.,\"#{sid}\")]"
        name_el = link_element(xpath: "#{row_xpath}//a[@data-ng-bind=\"student.sortableName\"]")
        sid_el = span_element(xpath: "#{row_xpath}//span[@data-ng-bind='student.sid']")
        major_els = driver.find_elements(xpath: "#{row_xpath}//div[@data-ng-repeat='major in student.majors']")
        term_units_el = div_element(xpath: "#{row_xpath}//div[contains(@data-ng-bind,'student.term.enrolledUnits')]")
        cumul_units_el = div_element(xpath: "#{row_xpath}//div[contains(@data-ng-bind,'student.cumulativeUnits')]")
        no_cumul_units_el = div_element(xpath: "#{row_xpath}//div[contains(@data-ng-if,'!student.cumulativeUnits')]")
        gpa_el = div_element(xpath: "#{row_xpath}//div[contains(@data-ng-bind, 'student.cumulativeGPA')]")
        no_gpa_el = div_element(xpath: "#{row_xpath}//div[contains(@data-ng-if, '!student.cumulativeGPA')]")
        alerts_el = div_element(xpath: "#{row_xpath}//div[contains(@class,'home-issues-pill')]")
        {
            :name => (name_el.text if name_el.exists?),
            :sid => (sid_el.text if sid_el.exists?),
            :major => major_els.map(&:text),
            :term_units => (term_units_el.text if term_units_el.exists?),
            :cumulative_units => (cumul_units_el.exists? ? cumul_units_el.text : no_cumul_units_el.text),
            :gpa => (gpa_el.exists? ? gpa_el.text : no_gpa_el.text),
            :alert_count => (alerts_el.text if alerts_el.exists?)
        }
      end

      # SORTING FOR STUDENT LISTS (shared by homepage and search results page)

      # Sorts a student list by a given option. If a cohort is given, then sorts the user list under the cohort.
      # @param option [String]
      # @param cohort [Cohort]
      def sort_by_option(option, cohort = nil)
        logger.info "Sorting by #{option}"
        xpath = filtered_cohort_xpath cohort if cohort && cohort.instance_of?(FilteredCohort)
        wait_for_update_and_click row_element(xpath: "#{xpath}//th[contains(@class, \"group-summary-column\")][contains(.,\"#{option}\")]")
      end

      # LAST NAME

      # Sorts a user list by name
      # @param cohort [Cohort]
      def sort_by_name(cohort = nil)
        sort_by_option('Name', cohort)
      end

      # Returns the sequence of SIDs that should be present when sorted by last name
      # @param user_data [Array<Hash>]
      # @return [Array<String>]
      def expected_sids_by_last_name(user_data)
        sorted_users = user_data.sort_by { |u| [u[:last_name_sortable].downcase, u[:first_name_sortable].downcase, u[:sid]] }
        sorted_users.map { |u| u[:sid] }
      end

      # SID

      # Sorts a user list by SID
      # @param cohort [Cohort]
      def sort_by_sid(cohort = nil)
        sort_by_option('SID', cohort)
      end

      # Returns the sequence of SIDs that should be present when sorted by SID
      # @param user_data [Array<Hash>]
      # @return [Array<String>]
      def expected_sids_by_sid(user_data)
        sorted_users = user_data.sort_by { |u| [u[:sid]] }
        sorted_users.map { |u| u[:sid] }
      end

      # MAJOR

      # Sorts a user list by major
      # @param cohort [Cohort]
      def sort_by_major(cohort = nil)
        sort_by_option('Major', cohort)
      end

      # Returns the sequence of SIDs that should be present when sorted by major
      # @param user_data [Array<Hash>]
      # @return [Array<String>]
      def expected_sids_by_major(user_data)
        sorted_users = user_data.sort_by { |u| [u[:major].sort.first.gsub(/\W/, '').downcase, u[:sid]] }
        sorted_users.map { |u| u[:sid] }
      end

      # EXPECTED GRADUATION

      # Sorts a user list by expected graduation term
      # @param cohort [Cohort]
      def sort_by_expected_grad(cohort = nil)
        sort_by_option('Grad', cohort)
      end

      # Returns the sequence of SIDs that should be present when sorted by expected graduation term
      # @param user_data [Array<Hash>]
      # @return [Array<String>]
      def expected_sids_by_grad_term(user_data)
        sorted_users = user_data.sort_by { |u| [u[:expected_grad_term_id], u[:sid]] }
        sorted_users.map { |u| u[:sid] }
      end

      # TERM UNITS

      # Sorts a user list by term units
      # @param cohort [Cohort]
      def sort_by_term_units(cohort = nil)
        sort_by_option('Term Units', cohort)
      end

      # Returns the sequence of SIDs that should be present when sorted by term units
      # @param user_data [Array<Hash>]
      # @return [Array<String>]
      def expected_sids_by_term_units(user_data)
        sorted_users = user_data.sort_by { |u| [u[:term_units].to_f, u[:sid]] }
        sorted_users.map { |u| u[:sid] }
      end

      # UNITS COMPLETED

      # Sorts a user list by cumulative units
      # @param cohort [Cohort]
      def sort_by_cumul_units(cohort = nil)
        sort_by_option('Units Completed', cohort)
      end

      # Returns the sequence of SIDs that should be present when sorted by cumulative units
      # @param user_data [Array<Hash>]
      # @return [Array<String>]
      def expected_sids_by_units_cum(user_data)
        sorted_users = user_data.sort_by { |u| [u[:units_completed].to_f, u[:sid]] }
        sorted_users.map { |u| u[:sid] }
      end

      # GPA

      # Sorts a user list by GPA
      # @param cohort [Cohort]
      def sort_by_gpa(cohort = nil)
        sort_by_option('GPA', cohort)
      end

      # Returns the sequence of SIDs that should be present when sorted by GPA
      # @param user_data [Array<Hash>]
      # @return [Array<String>]
      def expected_sids_by_gpa(user_data)
        sorted_users = user_data.sort_by { |u| [u[:gpa].to_f, u[:sid]] }
        sorted_users.map { |u| u[:sid] }
      end

      # ISSUES

      # Sorts a user list by alert count
      # @param cohort [Cohort]
      def sort_by_alert_count(cohort = nil)
        sort_by_option('Issues', cohort)
      end

      # Returns the sequence of SIDs that should be present when sorted by alert count
      # @param user_data [Array<Hash>]
      # @return [Array<String>]
      def expected_sids_by_alerts(user_data)
        sorted_users = user_data.sort_by { |u| [u[:alert_count], u[:sid]] }
        sorted_users.map { |u| u[:sid] }
      end

    end
  end
end