# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_05_17_124334) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "alas_types", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "areas", force: :cascade do |t|
    t.integer "area_id"
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "district_id"
    t.string "base_url"
    t.boolean "is_default", default: false
  end

  create_table "districts", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "file_uploads", force: :cascade do |t|
    t.text "data"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "gps_plottings", force: :cascade do |t|
    t.string "fullname"
    t.string "on_behalf"
    t.integer "act_for"
    t.string "hak_number"
    t.string "lattitude"
    t.string "longitude"
    t.text "land_address"
    t.datetime "deleted_at"
    t.bigint "user_id", null: false
    t.bigint "sub_district_id", null: false
    t.bigint "village_id", null: false
    t.bigint "hak_type_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "workspace_id"
    t.datetime "sent_at"
    t.integer "status"
    t.integer "certificate_status"
    t.integer "alas_type_id"
    t.string "alas_hak_number"
    t.index ["hak_type_id"], name: "index_gps_plottings_on_hak_type_id"
    t.index ["sub_district_id"], name: "index_gps_plottings_on_sub_district_id"
    t.index ["user_id"], name: "index_gps_plottings_on_user_id"
    t.index ["village_id"], name: "index_gps_plottings_on_village_id"
  end

  create_table "hak_types", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "intips", force: :cascade do |t|
    t.bigint "sub_district_id", null: false
    t.bigint "village_id", null: false
    t.string "nui"
    t.string "nib"
    t.string "name"
    t.datetime "date"
    t.string "time_range"
    t.string "land_control"
    t.string "land_allocation"
    t.string "land_use"
    t.string "land_utilization"
    t.string "land_size"
    t.string "land_address"
    t.string "description"
    t.string "lattitude"
    t.string "longitude"
    t.string "number_letter_c"
    t.string "hak_number"
    t.integer "status"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "workspace_id"
    t.datetime "sent_at"
    t.integer "certificate_status"
    t.integer "alas_type_id"
    t.integer "hak_type_id"
    t.index ["sub_district_id"], name: "index_intips_on_sub_district_id"
    t.index ["village_id"], name: "index_intips_on_village_id"
  end

  create_table "notes", force: :cascade do |t|
    t.integer "note_type"
    t.string "name"
    t.text "description"
    t.bigint "submission_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["submission_id"], name: "index_notes_on_submission_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "recipient_id"
    t.integer "actor_id"
    t.datetime "read_at"
    t.string "notifiable_type"
    t.integer "notifiable_id"
    t.string "action"
    t.text "message"
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "notif_type"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sub_districts", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "district_id"
  end

  create_table "submission_files", force: :cascade do |t|
    t.text "description"
    t.integer "file_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "submissionable_id"
    t.string "submissionable_type"
  end

  create_table "submissions", force: :cascade do |t|
    t.string "fullname"
    t.string "on_behalf"
    t.integer "act_for"
    t.date "submission_date"
    t.string "submission_code"
    t.string "lattitude"
    t.string "longitude"
    t.text "land_address"
    t.string "hak_number"
    t.date "pick_up_date"
    t.date "date_of_completion"
    t.text "notes"
    t.string "submission_status"
    t.string "land_book_status"
    t.text "land_book_description"
    t.string "kasubsi_status"
    t.string "kasubsi_registration_status"
    t.string "kasubsi_tematik_status"
    t.string "kasubsi_space_pattern_status"
    t.string "space_pattern_status"
    t.bigint "user_id", null: false
    t.bigint "hak_type_id", null: false
    t.bigint "service_id", null: false
    t.bigint "sub_district_id", null: false
    t.bigint "village_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_deleted", default: false
    t.date "deleted_at"
    t.string "registration_code"
    t.integer "admin_referral"
    t.string "nib"
    t.index ["hak_type_id"], name: "index_submissions_on_hak_type_id"
    t.index ["service_id"], name: "index_submissions_on_service_id"
    t.index ["sub_district_id"], name: "index_submissions_on_sub_district_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
    t.index ["village_id"], name: "index_submissions_on_village_id"
  end

  create_table "user_details", force: :cascade do |t|
    t.string "fullname"
    t.string "id_number"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "address"
    t.text "phone_number"
    t.index ["user_id"], name: "index_user_details_on_user_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "username", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "reset_password_code"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "villages", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "sub_district_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["sub_district_id"], name: "index_villages_on_sub_district_id"
  end

  create_table "working_areas", force: :cascade do |t|
    t.bigint "area_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["area_id"], name: "index_working_areas_on_area_id"
    t.index ["user_id"], name: "index_working_areas_on_user_id"
  end

  create_table "workspaces", force: :cascade do |t|
    t.bigint "village_id", null: false
    t.bigint "sub_district_id", null: false
    t.bigint "district_id", null: false
    t.bigint "user_id", null: false
    t.string "name"
    t.string "rt"
    t.string "rw"
    t.datetime "date_from"
    t.datetime "date_to"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["district_id"], name: "index_workspaces_on_district_id"
    t.index ["sub_district_id"], name: "index_workspaces_on_sub_district_id"
    t.index ["user_id"], name: "index_workspaces_on_user_id"
    t.index ["village_id"], name: "index_workspaces_on_village_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "gps_plottings", "hak_types"
  add_foreign_key "gps_plottings", "sub_districts"
  add_foreign_key "gps_plottings", "users"
  add_foreign_key "gps_plottings", "villages"
  add_foreign_key "intips", "sub_districts"
  add_foreign_key "intips", "villages"
  add_foreign_key "notes", "submissions"
  add_foreign_key "submissions", "hak_types"
  add_foreign_key "submissions", "services"
  add_foreign_key "submissions", "sub_districts"
  add_foreign_key "submissions", "users"
  add_foreign_key "submissions", "villages"
  add_foreign_key "user_details", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "villages", "sub_districts"
  add_foreign_key "working_areas", "areas"
  add_foreign_key "working_areas", "users"
  add_foreign_key "workspaces", "districts"
  add_foreign_key "workspaces", "sub_districts"
  add_foreign_key "workspaces", "users"
  add_foreign_key "workspaces", "villages"
end
