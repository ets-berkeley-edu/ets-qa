require_relative '../util/spec_helper'

module Page

  include PageObject
  include Logging

  # Switches browser focus into the Canvas LTI tool iframe. For Junction tests, pass the Junction base URL to verify that the tool
  # is configured with the right Junction environment before proceeding.
  # @param driver [Selenium::WebDriver]
  # @param url [String]
  def switch_to_canvas_iframe(driver, url = nil)
    hide_canvas_footer_and_popup
    wait_until(Utils.medium_wait) { driver.find_element(id: 'tool_content') }
    if url
      wait_until(1, "'#{url}' is not present") { i_frame_form_element? url }
      logger.warn "Found expected iframe base URL #{url}"
    end
    driver.switch_to.frame driver.find_element(id: 'tool_content')
  end

  # Whether or not an iframe containing a given URL exists
  # @param url [String]
  # @return [boolean]
  def i_frame_form_element?(url)
    form_element(xpath: "//form[contains(@action, '#{url}')]").exists?
  end

  # Hides the Canvas footer element in order to interact with elements hidden beneath it. Clicks once to set focus on the footer
  # and once again to hide it, with a retry in case the footer itself is obstructed.
  def hide_canvas_footer_and_popup
    if (browser_warning = button_element(xpath: '//li[@class="ic-flash-warning"]//button')).exists?
      browser_warning.click
      browser_warning.when_not_present Utils.short_wait
    end
    if (footer = div_element(id: 'element_toggler_0')).exists? && footer.visible?
      tries ||= 2
      begin
        footer.click
        sleep 1
        footer.click if footer.visible?
      rescue => e
        Utils.log_error e
        (tries -= 1).zero? ? fail : (sleep 2; retry)
      end
    end
  end

  # Waits for an element to exist and to become visible
  # @param element [PageObject::Elements::Element]
  # @param timeout [Fixnum]
  def wait_for_element(element, timeout)
    element.when_present timeout
    element.when_visible timeout
    sleep Utils.event_wait
  end

  # Awaits an element for a given timeout then clicks it using WebDriver click method.
  # @param element [PageObject::Elements::Element]
  # @param timeout [Fixnum]
  def click_element(element, timeout)
    wait_for_element(element, timeout)
    hide_canvas_footer_and_popup
    scroll_to_element element
    sleep Utils.click_wait
    element.click
  end

  def js_click(element)
    begin
      tries ||= 2
      begin
        element.when_present Utils.short_wait
        execute_script('arguments[0].click();', element)
      rescue Selenium::WebDriver::Error::UnknownError
        (tries -= 1).zero? ? fail : retry
      end
    rescue
      # If clicking an element using JavaScript fails, then try the WebDriver method.
      click_element(element, Utils.short_wait)
    end
  end

  # Awaits an element for a given timeout then clicks it using JavaScript.
  # @param element [PageObject::Elements::Element]
  # @param timeout [Fixnum]
  def click_element_js(element, timeout)
    wait_for_element(element, timeout)
    sleep Utils.click_wait
    js_click element
  end

  # Awaits an element for a short time then clicks it using WebDriver. Intended for DOM updates rather than page loads.
  # @param element [PageObject::Elements::Element]
  def wait_for_update_and_click(element)
    # When clicking Canvas elements, the footer might be in the way. Hide it if it exists.
    execute_script('arguments[0].style.hidden="hidden";', div_element(id: 'fixed_bottom')) if div_element(id: 'fixed_bottom').exists?
    click_element(element, Utils.short_wait)
  end

  # Awaits an element for a short time then clicks it using JavaScript. Intended for DOM updates rather than page loads.
  # @param element [PageObject::Elements::Element]
  def wait_for_update_and_click_js(element)
    click_element_js(element, Utils.short_wait)
  end

  # Awaits an element for a moderate time then clicks it using WebDriver. Intended for page loads rather than DOM updates.
  # @param element [PageObject::Elements::Element]
  def wait_for_load_and_click(element)
    click_element(element, Utils.medium_wait)
  end

  # Awaits an element for a moderate time then clicks it using JavaScript. Intended for page loads rather than DOM updates.
  # @param element [PageObject::Elements::Element]
  def wait_for_load_and_click_js(element)
    click_element_js(element, Utils.medium_wait)
  end

  # Awaits an element for a short time, clicks it using WebDriver, removes existing text, and sends new text. Intended for placing text
  # in input or textarea elements.
  # @param element [PageObject::Elements::Element]
  # @param text [String]
  def wait_for_element_and_type(element, text)
    wait_for_update_and_click element
    sleep Utils.click_wait
    element.clear
    element.send_keys text
  end

  # Awaits an element for a short time, clicks it using JavaScript, removes existing text, and sends new text. Intended for placing text
  # in input or textarea elements.
  # @param element [PageObject::Elements::Element]
  # @param text [String]
  def wait_for_element_and_type_js(element, text)
    wait_for_update_and_click_js element
    element.clear
    element.send_keys text
  end

  # Awaits a select element for a short time, clicks it using JavaScript, waits for a certain option to appear, and selects that option.
  # @param select_element [PageObject::Elements::SelectList]
  # @param option [String]
  def wait_for_element_and_select_js(select_element, option)
    wait_for_update_and_click_js select_element
    wait_until(Utils.short_wait) { (select_element.options.map { |o| o.text.strip }).include? option }
    option_to_select = (select_element.options.find { |o| o.text.strip == option })
    option_to_select.click
  end

  # Returns true if a code block completes without error.
  # @return [boolean]
  def verify_block(&blk)
    begin
      return true if yield
    rescue => e
      logger.debug e.message
      false
    end
  end

  # Opens a new browser tab, switches focus to it, and returns its handle
  # @param driver [Selenium::WebDriver]
  # @return [String]
  def open_new_window(driver)
    driver.execute_script('window.open()')
    driver.switch_to.window driver.window_handles.last
    driver.window_handle
  end

  # Clicks a link that should open in a new browser window and verifies that the expected page title loads on the new window.
  # @param driver [Selenium::WebDriver]
  # @param link [PageObject::Elements::Element]
  # @param expected_page_title [String]
  # @return [boolean]
  def external_link_valid?(driver, link, expected_page_title)
    begin
      original_window = driver.window_handle
      wait_for_load_and_click_js link
      sleep 2
      if driver.window_handles.length > 1
        driver.switch_to.window driver.window_handles.last
        wait_until(Utils.short_wait) { driver.find_element(xpath: "//title[contains(.,\"#{expected_page_title}\")]") }
        logger.debug "Found new window with title '#{expected_page_title}'"
        true
      else
        logger.error 'Link did not open in a new window'
        logger.debug "Expecting page title #{expected_page_title}, but visible page title is #{driver.title}"
        false
      end
    rescue => e
      Utils.log_error e
      false
    ensure
      if driver.window_handles.length > 1
        # Handle any alert that might appear when opening the new window
        driver.switch_to.alert.accept rescue Selenium::WebDriver::Error::NoAlertPresentError
        driver.close
        # Handle any alert that might appear when closing the new window
        driver.switch_to.alert.accept rescue Selenium::WebDriver::Error::NoAlertPresentError
      end
      driver.switch_to.window original_window
    end
  end

  # Uses JavaScript to scroll to the bottom of a page. This is a workaround for a WebDriver bug where certain elements
  # are not scrolled into focus prior to an interaction.
  def scroll_to_bottom
    sleep Utils.click_wait
    execute_script 'window.scrollTo(0, document.body.scrollHeight);'
  end

  # Uses JavaScript to scroll an element into view. If the attempt fails, it tries once more.
  # @param element [PageObject::Elements::Element]
  def scroll_to_element(element)
    tries ||= 2
    begin
      execute_script('arguments[0].scrollIntoView(true);', element)
    rescue Selenium::WebDriver::Error::UnknownError
      retry unless (tries -= 1).zero?
    end
  end

  # Hovers over an element with optional offsets, pausing to allow any events triggered by the action to occur.
  # @param driver [Selenium::WebDriver]
  # @param element [Selenium::WebDriver::Element]
  # @param horizontal_offset [Integer]
  # @param vertical_offset [Integer]
  def mouseover(driver, element, horizontal_offset = nil, vertical_offset = nil)
    scroll_to_element element
    driver.action.move_to(element, horizontal_offset, vertical_offset).perform
    sleep Utils.click_wait
  end

  # Pauses to allow the Canvas poller to complete any active cycle
  def pause_for_poller
    logger.info "Waiting for the Canvas poller for #{wait = SuiteCUtils.canvas_poller_wait} seconds"
    sleep wait
  end

  # Given a unique identifier and event data, adds a row with data about a user action that occurred during a test run, for comparison with
  # the application's own analytic event tracking.
  # @param event [Event]
  # @param event_type [EventType]
  # @param event_object [String]
  def add_event(event, event_type, event_object = nil)
    if event
      event.object = event_object
      values = [(event.time_str = Time.now.strftime('%Y-%m-%d %H:%M:%S')), event.actor.uid, (event.action = event_type).desc, event.object]
      csv = if EventType::CALIPER_EVENT_TYPES.include?(event_type)
              event.csv = LRSUtils.events_csv event
            elsif EventType::SUITEC_EVENT_TYPES.include?(event_type)
              logger.debug "Adding SuiteC event '#{event_type.desc}'"
              event.csv = SuiteCUtils.script_events_csv event
            else
              logger.error 'Event type not recognized'
            end
      csv ? Utils.add_csv_row(csv, values, %w(Time Actor Action Object)) : fail
    end
  end

  # Pauses to allow enough time for Canvas live events to be consumed and stored in the LRS db
  def wait_for_event
    wait = Utils.medium_wait
    logger.info "Pausing for #{wait} seconds for events to make it from Canvas to the LRS"
    sleep wait
  end

end
