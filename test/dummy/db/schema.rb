# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 702110110) do
  create_table "lesli_accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "email", null: false
    t.string "name"
    t.string "region", default: "america"
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["deleted_at"], name: "index_lesli_accounts_on_deleted_at"
    t.index ["email"], name: "index_lesli_accounts_on_email", unique: true
    t.index ["user_id"], name: "index_lesli_accounts_on_user_id"
  end

  create_table "lesli_resources", force: :cascade do |t|
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "engine"
    t.string "identifier"
    t.string "label"
    t.integer "parent_id"
    t.string "route"
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_lesli_resources_on_deleted_at"
    t.index ["parent_id"], name: "index_lesli_resources_on_parent_id"
  end

  create_table "lesli_roles", force: :cascade do |t|
    t.integer "account_id"
    t.boolean "active"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.datetime "deployed_at"
    t.string "description"
    t.boolean "isolated", default: false
    t.datetime "modified_at"
    t.string "name"
    t.string "path_default"
    t.boolean "path_limited"
    t.integer "permission_level", default: 10
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_lesli_roles_on_account_id"
    t.index ["deleted_at"], name: "index_lesli_roles_on_deleted_at"
  end

  create_table "lesli_support_accounts", force: :cascade do |t|
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.datetime "enabled_at"
    t.string "name"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_lesli_support_accounts_on_account_id"
    t.index ["deleted_at"], name: "index_lesli_support_accounts_on_deleted_at"
  end

  create_table "lesli_support_catalog_items", force: :cascade do |t|
    t.integer "catalog_id", null: false
    t.datetime "created_at", null: false
    t.boolean "default", default: false
    t.string "name"
    t.integer "order"
    t.datetime "updated_at", null: false
    t.index ["catalog_id"], name: "index_lesli_support_catalog_items_on_catalog_id"
  end

  create_table "lesli_support_catalogs", force: :cascade do |t|
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.string "key"
    t.string "name"
    t.integer "parent_id"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_lesli_support_catalogs_on_account_id"
    t.index ["key"], name: "index_lesli_support_catalogs_on_key"
    t.index ["parent_id"], name: "index_lesli_support_catalogs_on_parent_id"
  end

  create_table "lesli_support_item_activities", force: :cascade do |t|
    t.integer "account_id"
    t.string "activity_code"
    t.string "activity_type", default: "activity", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "description"
    t.json "metadata", default: {}
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["account_id", "subject_type", "subject_id"], name: "lesli_support_item_activities_activities_type_id"
    t.index ["account_id"], name: "index_lesli_support_item_activities_on_account_id"
    t.index ["deleted_at"], name: "index_lesli_support_item_activities_on_deleted_at"
    t.index ["user_id"], name: "index_lesli_support_item_activities_on_user_id"
  end

  create_table "lesli_support_item_discussions", force: :cascade do |t|
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.bigint "discussable_id", null: false
    t.string "discussable_type", null: false
    t.text "message"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["account_id"], name: "index_lesli_support_item_discussions_on_account_id"
    t.index ["deleted_at"], name: "index_lesli_support_item_discussions_on_deleted_at"
    t.index ["user_id"], name: "index_lesli_support_item_discussions_on_user_id"
  end

  create_table "lesli_support_item_tasks", force: :cascade do |t|
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.boolean "done", default: false, null: false
    t.bigint "taskable_id", null: false
    t.string "taskable_type", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["account_id", "taskable_type", "taskable_id"], name: "lesli_support_item_tasks_taskable_type_id"
    t.index ["account_id"], name: "index_lesli_support_item_tasks_on_account_id"
    t.index ["deleted_at"], name: "index_lesli_support_item_tasks_on_deleted_at"
    t.index ["user_id"], name: "index_lesli_support_item_tasks_on_user_id"
  end

  create_table "lesli_support_slas", force: :cascade do |t|
    t.integer "accounts_id"
    t.text "body"
    t.text "client_repercussions"
    t.datetime "created_at", null: false
    t.boolean "default", default: false
    t.datetime "deleted_at", precision: nil
    t.text "exceptions"
    t.integer "expected_resolution_time"
    t.integer "expected_response_time"
    t.string "name"
    t.float "price_per_hour"
    t.text "provider_repercussions"
    t.datetime "updated_at", null: false
    t.integer "users_id"
    t.index ["accounts_id"], name: "index_lesli_support_slas_on_accounts_id"
    t.index ["deleted_at"], name: "index_lesli_support_slas_on_deleted_at"
    t.index ["users_id"], name: "index_lesli_support_slas_on_users_id"
  end

  create_table "lesli_support_tickets", force: :cascade do |t|
    t.integer "account_id"
    t.integer "category_id"
    t.string "channel"
    t.datetime "closed_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "deadline_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.text "description"
    t.decimal "hours_worked"
    t.datetime "last_response_at", precision: nil
    t.datetime "opened_at", precision: nil
    t.integer "owner_id"
    t.integer "priority_id"
    t.string "reference_url"
    t.integer "sla_id"
    t.datetime "solved_at", precision: nil
    t.string "subject"
    t.string "tags"
    t.integer "type_id"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "workspace_id"
    t.index ["account_id"], name: "index_lesli_support_tickets_on_account_id"
    t.index ["category_id"], name: "index_lesli_support_tickets_on_category_id"
    t.index ["closed_at"], name: "index_lesli_support_tickets_on_closed_at"
    t.index ["deadline_at"], name: "index_lesli_support_tickets_on_deadline_at"
    t.index ["deleted_at"], name: "index_lesli_support_tickets_on_deleted_at"
    t.index ["last_response_at"], name: "index_lesli_support_tickets_on_last_response_at"
    t.index ["opened_at"], name: "index_lesli_support_tickets_on_opened_at"
    t.index ["owner_id"], name: "index_lesli_support_tickets_on_owner_id"
    t.index ["priority_id"], name: "index_lesli_support_tickets_on_priority_id"
    t.index ["sla_id"], name: "index_lesli_support_tickets_on_sla_id"
    t.index ["solved_at"], name: "index_lesli_support_tickets_on_solved_at"
    t.index ["type_id"], name: "index_lesli_support_tickets_on_type_id"
    t.index ["uid"], name: "index_lesli_support_tickets_on_uid", unique: true
    t.index ["user_id"], name: "index_lesli_support_tickets_on_user_id"
    t.index ["workspace_id"], name: "index_lesli_support_tickets_on_workspace_id"
  end

  create_table "lesli_users", force: :cascade do |t|
    t.integer "account_id"
    t.boolean "active", default: true, null: false
    t.string "alias"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.datetime "deleted_at"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.datetime "locked_until"
    t.datetime "password_expiration_at"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "salutation"
    t.integer "sign_in_count", default: 0, null: false
    t.string "telephone"
    t.datetime "telephone_confirmation_sent_at"
    t.string "telephone_confirmation_token"
    t.datetime "telephone_confirmed_at"
    t.string "title"
    t.string "uid", null: false
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_lesli_users_on_account_id"
    t.index ["confirmation_token"], name: "index_lesli_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_lesli_users_on_deleted_at"
    t.index ["email"], name: "index_lesli_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_lesli_users_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_lesli_users_on_uid", unique: true
    t.index ["unlock_token"], name: "index_lesli_users_on_unlock_token", unique: true
  end

  add_foreign_key "lesli_accounts", "lesli_users", column: "user_id"
  add_foreign_key "lesli_resources", "lesli_resources", column: "parent_id"
  add_foreign_key "lesli_roles", "lesli_accounts", column: "account_id"
  add_foreign_key "lesli_support_accounts", "lesli_accounts", column: "account_id"
  add_foreign_key "lesli_support_catalog_items", "lesli_support_catalogs", column: "catalog_id"
  add_foreign_key "lesli_support_catalogs", "lesli_support_accounts", column: "account_id"
  add_foreign_key "lesli_support_catalogs", "lesli_support_catalogs", column: "parent_id"
  add_foreign_key "lesli_support_item_activities", "lesli_support_accounts", column: "account_id"
  add_foreign_key "lesli_support_item_activities", "lesli_users", column: "user_id"
  add_foreign_key "lesli_support_item_discussions", "lesli_support_accounts", column: "account_id"
  add_foreign_key "lesli_support_item_discussions", "lesli_users", column: "user_id"
  add_foreign_key "lesli_support_item_tasks", "lesli_support_accounts", column: "account_id"
  add_foreign_key "lesli_support_item_tasks", "lesli_users", column: "user_id"
  add_foreign_key "lesli_support_slas", "lesli_support_accounts", column: "accounts_id"
  add_foreign_key "lesli_support_slas", "lesli_users", column: "users_id"
  add_foreign_key "lesli_support_tickets", "lesli_support_accounts", column: "account_id"
  add_foreign_key "lesli_support_tickets", "lesli_support_catalog_items", column: "category_id"
  add_foreign_key "lesli_support_tickets", "lesli_support_catalog_items", column: "priority_id"
  add_foreign_key "lesli_support_tickets", "lesli_support_catalog_items", column: "type_id"
  add_foreign_key "lesli_support_tickets", "lesli_support_catalog_items", column: "workspace_id"
  add_foreign_key "lesli_support_tickets", "lesli_support_slas", column: "sla_id"
  add_foreign_key "lesli_support_tickets", "lesli_users", column: "owner_id"
  add_foreign_key "lesli_support_tickets", "lesli_users", column: "user_id"
  add_foreign_key "lesli_users", "lesli_accounts", column: "account_id"
end
