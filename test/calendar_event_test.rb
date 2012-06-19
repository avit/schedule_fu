require 'test_helper'

class CalendarEventTest < ActiveSupport::TestCase
  describe CalendarEvent do
    it { should validate_presence_of :calendar }
    it { should validate_presence_of :start_date }
    it { should validate_presence_of :calendar_event_type_id }
  end

  context "norepeat event" do
    setup do
      @event = FactoryGirl.create(:calendar_event_norepeat, :start_date => 1.day.from_now,
          :end_date => 2.weeks.from_now)
    end

    should "have no recurrences" do
      assert_equal 0, @event.recurrences.count
    end

    should "have 1 event date that matches the start date" do
      assert_equal 1, @event.dates.count
      assert_equal @event.start_date.to_date, @event.dates.first.value
    end
  end

  context "weekdays event" do
    setup do
      @event = FactoryGirl.create(:calendar_event_weekdays, :start_date => 1.day.from_now,
          :end_date => 2.weeks.from_now)
      @count_of_weekdays = Hash.new {|hash, key| hash[key] = 0}
      @event.dates.each do |d|
        @count_of_weekdays[d.weekday] += 1
      end
    end

    should "have no recurrences" do
      assert_equal 0, @event.recurrences.count
    end

    should "have 10 event dates" do
      assert_equal 10, @event.event_dates.count
    end

    should "have 2 of each weekday" do
      (1..5).each do |n|
        assert_equal 2, @count_of_weekdays[n]
      end
    end

    should "not have Sunday or Saturday" do
      [0,6].each do |n|
        assert_equal 0, @count_of_weekdays[n]
      end
    end
  end

  context "daily event with 14 event dates" do
    setup do
      @event = FactoryGirl.create(:calendar_event_daily, :start_date => 1.day.from_now,
          :end_date => 2.weeks.from_now)
    end

    should "have no recurrences" do
      assert_equal 0, @event.recurrences.count
    end

    should "have 14 event dates" do
      assert_equal 14, @event.event_dates.count
    end

    should "be in the correct range" do
      @event.dates.each do |d|
        assert d.value >= @event.start_date.to_date
        assert d.value <= @event.end_date.to_date
      end
    end
  end

  context "weekly event" do
    context "on Monday, Wednesday, and Friday with 6 event dates" do
      setup do
        @event = FactoryGirl.create(:calendar_event_weekly, :repeat_0 => false, :repeat_1 => true,
            :repeat_2 => false, :repeat_3 => true, :repeat_4 => false,
            :repeat_5 => true, :repeat_6 => false, :start_date => 1.day.from_now,
            :end_date => 2.weeks.from_now)
        @count_of_weekdays = Hash.new {|hash, key| hash[key] = 0}
        @event.dates.each do |d|
          @count_of_weekdays[d.weekday] += 1
        end
      end

      should "have 3 recurrences" do
        assert_equal 3, @event.recurrences.count
      end

      should "have 6 event dates" do
        assert_equal 6, @event.event_dates.count
      end

      should "have 2 each of Monday, Wednesday, and Friday" do
        [1,3,5].each do |n|
          assert_equal 2, @count_of_weekdays[n]
        end
      end

      should "not have Sunday, Tuesday, Thursday, or Saturday" do
        [0,2,4,6].each do |n|
          assert_equal 0, @count_of_weekdays[n]
        end
      end
    end
  end

  context "monthly event" do
    context "by the day of month with 6 months" do
      def setup_monthly_by_day_of_month(start_date)
        event = FactoryGirl.create(:calendar_event_monthly, :by_day_of_month => true,
            :start_date => start_date, :end_date => 5.months.from_now)
        event_count = 1
        (1..5).each {|n| event_count += 1 if start_date.day == (start_date + n.month).day}
        return event, event_count
      end

      context "with a random date" do
        setup do
          @event, @event_count = setup_monthly_by_day_of_month(1.week.ago)
        end

        should "have 1 recurrence" do
          assert_equal 1, @event.recurrences.count
        end

        should "have the correct number of event dates" do
          assert_equal @event_count, @event.event_dates.count
        end

        should "have the correct day of month" do
          @event.dates.each do |d|
            assert_equal @event.recurrences.first.monthday, d.monthday
          end
        end
      end

      context "with 01-31-2012" do
        setup do
          @event, @event_count = setup_monthly_by_day_of_month(Date.parse('2012-01-31'))
        end

        should "have 1 recurrence" do
          assert_equal 1, @event.recurrences.count
        end

        should "have the correct number of event dates" do
          assert_equal @event_count, @event.event_dates.count
        end

        should "have the correct day of month" do
          @event.dates.each do |d|
            assert_equal @event.recurrences.first.monthday, d.monthday
          end
        end
      end
    end

    context "by day of week with 6 months" do
      def setup_monthly_by_date_of_week(start_date)
        start_date = start_date.to_date
        event = FactoryGirl.create(:calendar_event_monthly, :by_day_of_month => false,
            :start_date => start_date, :end_date => 5.months.from_now)
        event_count = 1
        monthweek = (start_date.mday - 1) / 7
        (1..5).each do |n|
          new_date = (start_date + n.months).beginning_of_month
          until new_date.wday == start_date.wday
            new_date = new_date.next
          end
          new_date += monthweek.weeks
          event_count += 1 if (start_date + n.months).month == new_date.month
        end
        return event, event_count
      end

      context "with a random date" do
        setup do
          @event, @event_count = setup_monthly_by_date_of_week(1.week.ago)
        end

        should "have 1 recurrence" do
          assert_equal 1, @event.recurrences.count
        end

        should "have the correct number of event dates" do
          assert_equal @event_count, @event.event_dates.count
        end

        should "have the correct day of week" do
          @event.dates.each do |d|
            assert_equal @event.recurrences.first.weekday, d.weekday
          end
        end

        should "have the correct week" do
          @event.dates.each do |d|
            assert_equal @event.recurrences.first.monthweek, d.monthweek
          end
        end
      end

      context "with 02-29-2012" do
        setup do
          @event, @event_count = setup_monthly_by_date_of_week(Date.parse('2012-02-29'))
        end

        should "have 1 recurrence" do
          assert_equal 1, @event.recurrences.count
        end

        should "have the correct number of event dates" do
          assert_equal @event_count, @event.event_dates.count
        end

        should "have the correct day of week" do
          @event.dates.each do |d|
            assert_equal @event.recurrences.first.weekday, d.weekday
          end
        end

        should "have the correct week" do
          @event.dates.each do |d|
            assert_equal @event.recurrences.first.monthweek, d.monthweek
          end
        end
      end
    end
  end

  context "yearly event" do
    context "by day of month with 2 years" do
      def setup_yearly_event_by_day_of_month(start_date)
        event = FactoryGirl.create(:calendar_event_yearly, :by_day_of_month => true,
            :start_date => start_date, :end_date => 1.year.from_now)
        event_count = 1
        event_count = 2 if start_date.day == (start_date + 1.year).day
        return event, event_count
      end

      context "with a random date" do
        setup do
          @event, @event_count = setup_yearly_event_by_day_of_month(1.month.ago)
          @recurrence = @event.recurrences.first
        end

        should "have 1 recurrence" do
          assert_equal 1, @event.recurrences.count
        end

        should "have the correct number of event dates" do
          assert_equal @event_count, @event.event_dates.count
        end

        should "have the correct month" do
          @event.dates.each do |d|
            assert_equal @recurrence.month, d.month
          end
        end

        should "have the correct day of month" do
          @event.dates.each do |d|
            assert_equal @recurrence.monthday, d.monthday
          end
        end
      end

      context "with 02-29-2012" do
        setup do
          @event, @event_count = setup_yearly_event_by_day_of_month(Date.parse('2012-02-29'))
          @recurrence = @event.recurrences.first
        end

        should "have 1 recurrence" do
          assert_equal 1, @event.recurrences.count
        end

        should "have the correct number of event dates" do
          assert_equal @event_count, @event.event_dates.count
        end

        should "have the correct month" do
          @event.dates.each do |d|
            assert_equal @recurrence.month, d.month
          end
        end

        should "have the correct day of month" do
          @event.dates.each do |d|
            assert_equal @recurrence.monthday, d.monthday
          end
        end
      end
    end

    context "by day of week with 2 years" do
      def setup_yearly_event_by_day_of_week(start_date)
        event = FactoryGirl.create(:calendar_event_yearly, :by_day_of_month => false,
            :start_date => start_date, :end_date => 1.year.from_now)
        event_count = 1
        start_date = start_date.to_date
        monthweek = (start_date.mday - 1) / 7
        new_date = (start_date + 1.year).beginning_of_month
        until new_date.wday == start_date.wday
          new_date = new_date.next
        end
        new_date += monthweek.weeks
        event_count = 2 if (start_date + 1.year).month == new_date.month
        return event, event_count
      end

      context "with a random date" do
        setup do
          @event, @event_count = setup_yearly_event_by_day_of_week(1.month.ago)
          @recurrence = @event.recurrences.first
        end

        should "have 1 recurrence" do
          assert_equal 1, @event.recurrences.count
        end

        should "have the correct number of event dates" do
          assert_equal @event_count, @event.event_dates.count
        end

        should "have the correct month" do
          @event.dates.each do |d|
            assert_equal @recurrence.month, d.month
          end
        end

        should "have the correct day of week" do
          @event.dates.each do |d|
            assert_equal @recurrence.weekday, d.weekday
          end
        end

        should "have the correct week" do
          @event.dates.each do |d|
            assert_equal @recurrence.monthweek, d.monthweek
          end
        end
      end

      context "with 02-29-2012" do
        setup do
          @event, @event_count = setup_yearly_event_by_day_of_week(Date.parse('2012-02-29'))
          @recurrence = @event.recurrences.first
        end

        should "have 1 recurrence" do
          assert_equal 1, @event.recurrences.count
        end

        should "have the correct number of event dates" do
          assert_equal @event_count, @event.event_dates.count
        end

        should "have the correct month" do
          @event.dates.each do |d|
            assert_equal @recurrence.month, d.month
          end
        end

        should "have the correct day of week" do
          @event.dates.each do |d|
            assert_equal @recurrence.weekday, d.weekday
          end
        end

        should "have the correct week" do
          @event.dates.each do |d|
            assert_equal @recurrence.monthweek, d.monthweek
          end
        end
      end
    end
  end
end
