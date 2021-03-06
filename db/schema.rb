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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160731192652) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "image_tags", force: :cascade do |t|
    t.integer  "image_id"
    t.integer  "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "image_tags", ["image_id", "tag_id"], name: "index_image_tags_on_image_id_and_tag_id", unique: true, using: :btree
  add_index "image_tags", ["tag_id"], name: "index_image_tags_on_tag_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "links", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",       null: false
    t.string   "url",        null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "userfile_tags", force: :cascade do |t|
    t.integer  "userfile_id"
    t.integer  "tag_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "userfile_tags", ["tag_id"], name: "index_userfile_tags_on_tag_id", using: :btree
  add_index "userfile_tags", ["userfile_id", "tag_id"], name: "index_userfile_tags_on_userfile_id_and_tag_id", unique: true, using: :btree

  create_table "userfiles", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "location"
    t.string   "mimetype"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "preview_type", default: "none"
    t.string   "filename"
    t.string   "file_type"
    t.string   "content_type"
    t.integer  "file_size"
  end

  add_index "userfiles", ["user_id"], name: "index_userfiles_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
