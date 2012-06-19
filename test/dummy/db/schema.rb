# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120121210741) do

  create_table "calendar_dates", :force => true do |t|
    t.date    "value",                                     :null => false
    t.integer "weekday",   :limit => 1,                    :null => false
    t.integer "monthweek", :limit => 1,                    :null => false
    t.integer "monthday",  :limit => 1,                    :null => false
    t.integer "month",     :limit => 1,                    :null => false
    t.boolean "lastweek",               :default => false, :null => false
  end

  add_index "calendar_dates", ["value"], :name => "index_calendar_dates_on_value", :unique => true

  create_table "calendar_event_mods", :force => true do |t|
    t.integer "calendar_event_id",                    :null => false
    t.integer "calendar_date_id",                     :null => false
    t.time    "start_time"
    t.time    "end_time"
    t.text    "desc"
    t.text    "long_desc"
    t.boolean "removed",           :default => false, :null => false
  end

  add_index "calendar_event_mods", ["calendar_event_id", "calendar_date_id"], :name => "calendar_event_mods_for_event_and_date", :unique => true

  create_table "calendar_event_types", :force => true do |t|
    t.string "name"
    t.string "desc"
  end

  create_table "calendar_events", :force => true do |t|
    t.integer "calendar_id",                               :null => false
    t.integer "calendar_event_type_id"
    t.boolean "by_day_of_month",        :default => false, :null => false
    t.date    "start_date"
    t.date    "end_date"
    t.time    "start_time"
    t.time    "end_time"
    t.text    "desc"
    t.text    "long_desc"
  end

  create_table "calendar_recurrences", :force => true do |t|
    t.integer "calendar_event_id",              :null => false
    t.integer "weekday",           :limit => 1
    t.integer "monthweek",         :limit => 1
    t.integer "monthday",          :limit => 1
    t.integer "month",             :limit => 1
  end

  create_table "calendars", :force => true do |t|
    t.text "desc"
  end

  create_view "calendar_event_dates", "select `ce`.`id` AS `calendar_event_id`,`cd`.`id` AS `calendar_date_id`,`cem`.`id` AS `calendar_event_mod_id`,`cd`.`value` AS `date_value`,coalesce(`cem`.`start_time`,`ce`.`start_time`) AS `start_time`,coalesce(`cem`.`end_time`,`ce`.`end_time`) AS `end_time`,coalesce(`cem`.`desc`,`ce`.`desc`) AS `desc`,coalesce(`cem`.`long_desc`,`ce`.`long_desc`) AS `long_desc`,(((`ce`.`calendar_event_type_id` in (4,5,6)) and isnull(`cr`.`id`)) or ((`ce`.`start_date` is not null) and (`cd`.`value` < `ce`.`start_date`)) or ((`ce`.`end_date` is not null) and (`cd`.`value` > `ce`.`end_date`)) or ((`ce`.`calendar_event_type_id` = 2) and (`cd`.`weekday` not in (1,2,3,4,5)))) AS `added`,((`cem`.`id` is not null) and (`cem`.`removed` = 1)) AS `removed`,((`cem`.`id` is not null) and (`cem`.`removed` = 0) and ((`cem`.`start_time` is not null) or (`cem`.`end_time` is not null) or (`cem`.`desc` is not null) or (`cem`.`long_desc` is not null))) AS `modified` from (((`calendar_dates` `cd` left join `calendar_events` `ce` on((isnull(`ce`.`start_date`) or (`ce`.`start_date` is not null)))) left join `calendar_event_mods` `cem` on(((`cem`.`calendar_date_id` = `cd`.`id`) and (`cem`.`calendar_event_id` = `ce`.`id`)))) left join `calendar_recurrences` `cr` on(((`cr`.`calendar_event_id` = `ce`.`id`) and (`ce`.`calendar_event_type_id` in (4,5,6))))) where (((`cd`.`id` is not null) or (`cem`.`id` is not null)) and (((isnull(`ce`.`start_date`) or (`cd`.`value` >= `ce`.`start_date`)) and (isnull(`ce`.`end_date`) or (`cd`.`value` <= `ce`.`end_date`))) or (`cem`.`id` is not null)) and ((`cem`.`id` is not null) or ((`ce`.`calendar_event_type_id` = 1) and (`ce`.`start_date` = `cd`.`value`)) or ((`ce`.`calendar_event_type_id` = 2) and (`cd`.`weekday` in (1,2,3,4,5))) or (`ce`.`calendar_event_type_id` = 3) or ((`ce`.`calendar_event_type_id` = 4) and (`cr`.`weekday` = `cd`.`weekday`)) or ((`ce`.`calendar_event_type_id` = 5) and (((`ce`.`by_day_of_month` = 0) and (`cr`.`weekday` = `cd`.`weekday`) and ((`cr`.`monthweek` = `cd`.`monthweek`) or ((`cr`.`monthweek` = -(1)) and (`cd`.`lastweek` = 1)))) or ((`ce`.`by_day_of_month` = 1) and (`cr`.`monthday` = `cd`.`monthday`)))) or ((`ce`.`calendar_event_type_id` = 6) and (`cd`.`month` = `cr`.`month`) and (((`ce`.`by_day_of_month` = 0) and (`cr`.`weekday` = `cd`.`weekday`) and ((`cr`.`monthweek` = `cd`.`monthweek`) or ((`cr`.`monthweek` = -(1)) and (`cd`.`lastweek` = 1)))) or ((`ce`.`by_day_of_month` = 1) and (`cr`.`monthday` = `cd`.`monthday`))))))", :force => true do |v|
    v.column :calendar_event_id
    v.column :calendar_date_id
    v.column :calendar_event_mod_id
    v.column :date_value
    v.column :start_time
    v.column :end_time
    v.column :desc
    v.column :long_desc
    v.column :added
    v.column :removed
    v.column :modified
  end

end
