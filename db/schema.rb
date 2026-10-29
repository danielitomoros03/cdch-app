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

ActiveRecord::Schema[7.2].define(version: 2026_10_29_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "announcements", force: :cascade do |t|
    t.text "content"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "calls", force: :cascade do |t|
    t.string "title", null: false
    t.string "short_description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "kind"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.string "acronym"
    t.integer "organize"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
    t.string "official_name"
    t.boolean "public_visible", default: true, null: false
    t.bigint "parent_id"
    t.index ["code"], name: "index_departments_on_code", unique: true
    t.index ["parent_id"], name: "index_departments_on_parent_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.boolean "show_in"
    t.boolean "active"
    t.text "description"
    t.integer "kind"
    t.date "day"
    t.time "start_time"
    t.time "end_time"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "faculties", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_faculties_on_code", unique: true
  end

  create_table "funding_sources", force: :cascade do |t|
    t.string "code", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_funding_sources_on_code", unique: true
  end

  create_table "institution_leaderships", force: :cascade do |t|
    t.bigint "institution_id", null: false
    t.string "full_name", null: false
    t.integer "role", default: 0, null: false
    t.date "start_date", null: false
    t.date "end_date"
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["institution_id", "role"], name: "idx_inst_leadership_institution_role"
    t.index ["institution_id"], name: "index_institution_leaderships_on_institution_id"
    t.index ["role"], name: "index_institution_leaderships_on_role"
    t.index ["start_date"], name: "index_institution_leaderships_on_start_date"
  end

  create_table "institutional_aids", force: :cascade do |t|
    t.bigint "department_id", null: false
    t.integer "legacy_id", null: false
    t.string "aid_type_code"
    t.string "code"
    t.string "legacy_code"
    t.string "serial"
    t.bigint "applicant_person_id"
    t.string "faculty_code"
    t.string "dependency"
    t.text "description"
    t.bigint "legacy_status_id"
    t.date "requested_on"
    t.decimal "amount_requested", precision: 20, scale: 2
    t.date "approved_on"
    t.decimal "amount_approved", precision: 20, scale: 2
    t.decimal "amount_equipment", precision: 20, scale: 2
    t.decimal "amount_supplies", precision: 20, scale: 2
    t.decimal "amount_travel", precision: 20, scale: 2
    t.decimal "amount_services", precision: 20, scale: 2
    t.decimal "amount_other", precision: 20, scale: 2
    t.string "currency"
    t.boolean "amount_flagged", default: false, null: false
    t.date "report_approved_on"
    t.boolean "report_ok"
    t.date "extension_on"
    t.integer "extension_code"
    t.integer "duration_months"
    t.text "notes"
    t.string "merge_note"
    t.string "funding_source_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aid_type_code"], name: "index_institutional_aids_on_aid_type_code"
    t.index ["applicant_person_id"], name: "index_institutional_aids_on_applicant_person_id"
    t.index ["department_id"], name: "index_institutional_aids_on_department_id"
    t.index ["legacy_id"], name: "index_institutional_aids_on_legacy_id", unique: true
    t.index ["legacy_status_id"], name: "index_institutional_aids_on_legacy_status_id"
    t.index ["requested_on"], name: "index_institutional_aids_on_requested_on"
    t.check_constraint "currency IS NULL OR (currency::text = ANY (ARRAY['VEB'::character varying, 'VEF'::character varying, 'VES'::character varying, 'VED'::character varying]::text[]))", name: "institutional_aids_currency"
  end

  create_table "institutions", force: :cascade do |t|
    t.string "address"
    t.string "name"
    t.string "primary_phone"
    t.string "secondary_phone"
    t.string "primary_email"
    t.string "secondary_email"
    t.string "business_hours"
    t.text "mission"
    t.text "vission"
    t.string "twitter_url"
    t.string "facebook_url"
    t.string "instagram_url"
    t.string "threads_url"
    t.string "acronym"
    t.text "description"
    t.string "linkedin_url"
    t.string "director_name"
    t.string "director_primary_email"
    t.string "director_secondary_email"
    t.string "subdirector_name"
    t.string "subdirector_primary_email"
    t.string "subdirector_secondary_email"
    t.integer "founded_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "youtube_url"
  end

  create_table "job_titles", force: :cascade do |t|
    t.string "name"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legacy_statuses", force: :cascade do |t|
    t.integer "legacy_id", null: false
    t.string "name", null: false
    t.string "applies_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legacy_id"], name: "index_legacy_statuses_on_legacy_id", unique: true
  end

  create_table "minutes", force: :cascade do |t|
    t.date "day"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "peer_reviews", force: :cascade do |t|
    t.bigint "department_id", null: false
    t.integer "legacy_id", null: false
    t.bigint "project_stage_id"
    t.bigint "institutional_aid_id"
    t.string "legacy_code"
    t.integer "stage_number"
    t.bigint "reviewer_person_id"
    t.string "reviewer_name"
    t.string "letter_number"
    t.date "sent_on"
    t.date "answered_on"
    t.boolean "opinion_given"
    t.boolean "ratified"
    t.string "receipt"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_peer_reviews_on_department_id"
    t.index ["institutional_aid_id"], name: "index_peer_reviews_on_institutional_aid_id"
    t.index ["legacy_id"], name: "index_peer_reviews_on_legacy_id", unique: true
    t.index ["project_stage_id"], name: "index_peer_reviews_on_project_stage_id"
    t.index ["reviewer_person_id"], name: "index_peer_reviews_on_reviewer_person_id"
    t.index ["sent_on"], name: "index_peer_reviews_on_sent_on"
  end

  create_table "people", force: :cascade do |t|
    t.string "id_number", null: false
    t.string "nationality"
    t.string "first_names"
    t.string "last_names"
    t.string "full_name", null: false
    t.string "payroll_name"
    t.boolean "in_payroll", default: false, null: false
    t.string "payroll_status"
    t.string "legacy_condition"
    t.string "legacy_faculty_code"
    t.string "legacy_category"
    t.string "legacy_dedication"
    t.string "legacy_position"
    t.boolean "project_lead", default: false, null: false
    t.boolean "co_investigator", default: false, null: false
    t.boolean "reviewer", default: false, null: false
    t.boolean "aid_applicant", default: false, null: false
    t.boolean "scholar", default: false, null: false
    t.string "sources"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["full_name"], name: "index_people_on_full_name"
    t.index ["id_number"], name: "index_people_on_id_number", unique: true
    t.index ["payroll_status"], name: "index_people_on_payroll_status"
    t.check_constraint "payroll_status IS NULL OR (payroll_status::text = ANY (ARRAY['active'::character varying, 'management'::character varying, 'retired'::character varying]::text[]))", name: "people_payroll_status"
  end

  create_table "person_contacts", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "kind", null: false
    t.string "value", null: false
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id", "kind", "value"], name: "index_person_contacts_on_person_id_and_kind_and_value", unique: true
    t.index ["person_id"], name: "index_person_contacts_on_person_id"
    t.check_constraint "kind::text = ANY (ARRAY['email'::character varying, 'phone'::character varying, 'address'::character varying]::text[])", name: "person_contacts_kind"
  end

  create_table "ppi_levels", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "level"
    t.string "committee"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_ppi_levels_on_person_id"
  end

  create_table "project_stages", force: :cascade do |t|
    t.bigint "research_project_id", null: false
    t.integer "legacy_id", null: false
    t.integer "number"
    t.integer "total_stages"
    t.string "serial"
    t.bigint "lead_person_id"
    t.string "faculty_code"
    t.bigint "legacy_status_id"
    t.bigint "research_area_id"
    t.string "area_text"
    t.string "specialty"
    t.text "title"
    t.boolean "cofinanced"
    t.date "requested_on"
    t.decimal "amount_requested", precision: 20, scale: 2
    t.date "approved_on"
    t.string "contract"
    t.date "signed_on"
    t.decimal "amount_approved", precision: 20, scale: 2
    t.decimal "stage_variation", precision: 20, scale: 2
    t.decimal "amount_equipment", precision: 20, scale: 2
    t.decimal "amount_supplies", precision: 20, scale: 2
    t.decimal "amount_travel", precision: 20, scale: 2
    t.decimal "amount_services", precision: 20, scale: 2
    t.decimal "amount_personnel", precision: 20, scale: 2
    t.decimal "amount_other", precision: 20, scale: 2
    t.string "currency"
    t.boolean "amount_flagged", default: false, null: false
    t.date "partial_report_approved_on"
    t.boolean "partial_report_ok"
    t.date "final_report_approved_on"
    t.boolean "final_report_ok"
    t.text "notes"
    t.string "merge_note"
    t.date "extension_on"
    t.integer "extension_code"
    t.integer "duration_months"
    t.date "work_approved_on"
    t.text "work_title"
    t.text "work_journal"
    t.string "funding_source_code"
    t.string "code"
    t.string "legacy_code"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_person_id"], name: "index_project_stages_on_lead_person_id"
    t.index ["legacy_id"], name: "index_project_stages_on_legacy_id", unique: true
    t.index ["legacy_status_id"], name: "index_project_stages_on_legacy_status_id"
    t.index ["requested_on"], name: "index_project_stages_on_requested_on"
    t.index ["research_area_id"], name: "index_project_stages_on_research_area_id"
    t.index ["research_project_id"], name: "index_project_stages_on_research_project_id"
    t.check_constraint "currency IS NULL OR (currency::text = ANY (ARRAY['VEB'::character varying, 'VEF'::character varying, 'VES'::character varying, 'VED'::character varying]::text[]))", name: "project_stages_currency"
  end

  create_table "project_types", force: :cascade do |t|
    t.string "code", null: false
    t.string "name"
    t.string "program"
    t.boolean "current", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_project_types_on_code", unique: true
  end

  create_table "publications", force: :cascade do |t|
    t.string "title"
    t.string "author_name"
    t.date "date_publication"
    t.integer "kind", default: 0
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_url"
  end

  create_table "research_areas", force: :cascade do |t|
    t.integer "legacy_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legacy_id"], name: "index_research_areas_on_legacy_id", unique: true
  end

  create_table "research_projects", force: :cascade do |t|
    t.bigint "department_id", null: false
    t.string "project_type_code", null: false
    t.string "code", null: false
    t.string "legacy_code"
    t.text "title"
    t.bigint "lead_person_id"
    t.string "faculty_code"
    t.bigint "research_area_id"
    t.string "specialty"
    t.integer "total_stages"
    t.date "first_requested_on"
    t.date "last_requested_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_research_projects_on_department_id"
    t.index ["faculty_code"], name: "index_research_projects_on_faculty_code"
    t.index ["lead_person_id"], name: "index_research_projects_on_lead_person_id"
    t.index ["legacy_code"], name: "index_research_projects_on_legacy_code"
    t.index ["project_type_code", "code"], name: "index_research_projects_on_project_type_code_and_code", unique: true
    t.index ["project_type_code"], name: "index_research_projects_on_project_type_code"
    t.index ["research_area_id"], name: "index_research_projects_on_research_area_id"
  end

  create_table "scholarships", force: :cascade do |t|
    t.bigint "department_id", null: false
    t.integer "legacy_id", null: false
    t.bigint "person_id", null: false
    t.string "program"
    t.string "scholarship_type"
    t.string "level"
    t.string "specialty"
    t.string "institution"
    t.string "country"
    t.string "faculty"
    t.string "dependency"
    t.string "rank"
    t.string "dedication"
    t.date "approved_on"
    t.date "starts_on"
    t.date "ends_on"
    t.date "last_extension_on"
    t.date "degree_filed_on"
    t.string "status"
    t.string "file_number"
    t.text "notes"
    t.text "follow_up"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_scholarships_on_department_id"
    t.index ["legacy_id"], name: "index_scholarships_on_legacy_id", unique: true
    t.index ["person_id"], name: "index_scholarships_on_person_id"
  end

  create_table "solicitudes", force: :cascade do |t|
    t.string "full_name"
    t.string "email"
    t.string "phone_number"
    t.integer "matter"
    t.text "message"
    t.boolean "policies", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stage_co_investigators", force: :cascade do |t|
    t.bigint "project_stage_id"
    t.bigint "person_id", null: false
    t.string "project_code"
    t.integer "stage_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_stage_co_investigators_on_person_id"
    t.index ["project_stage_id"], name: "index_stage_co_investigators_on_project_stage_id"
  end

  create_table "stage_extensions", force: :cascade do |t|
    t.bigint "project_stage_id", null: false
    t.integer "stage_number"
    t.date "granted_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_stage_id"], name: "index_stage_extensions_on_project_stage_id"
  end

  create_table "stage_publications", force: :cascade do |t|
    t.bigint "project_stage_id"
    t.string "legacy_code"
    t.integer "stage_number"
    t.text "title"
    t.text "venue"
    t.date "evaluated_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_stage_id"], name: "index_stage_publications_on_project_stage_id"
  end

  create_table "ucv_appointments", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "payroll_type_code"
    t.string "payroll_type"
    t.string "dependency_code"
    t.string "dependency"
    t.string "ucv_unit_code"
    t.string "ucv_unit_name"
    t.date "hired_on"
    t.date "retired_on"
    t.integer "years_at_ucv"
    t.string "dedication_code"
    t.string "dedication"
    t.string "category_code"
    t.string "category"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_ucv_appointments_on_person_id"
    t.index ["ucv_unit_code"], name: "index_ucv_appointments_on_ucv_unit_code"
  end

  create_table "ucv_units", force: :cascade do |t|
    t.string "code", null: false
    t.string "short_code"
    t.string "name"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_ucv_units_on_code", unique: true
  end

  create_table "user_permissions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "resource", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "resource"], name: "index_user_permissions_on_user_id_and_resource", unique: true
    t.index ["user_id"], name: "index_user_permissions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.bigint "department_id", default: 0, null: false
    t.bigint "job_title_id", default: 0, null: false
    t.string "name"
    t.string "lastname"
    t.string "number_phone"
    t.string "identification_number"
    t.boolean "active", default: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["job_title_id"], name: "index_users_on_job_title_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "departments", "departments", column: "parent_id"
  add_foreign_key "institution_leaderships", "institutions"
  add_foreign_key "institutional_aids", "departments"
  add_foreign_key "institutional_aids", "legacy_statuses"
  add_foreign_key "institutional_aids", "people", column: "applicant_person_id"
  add_foreign_key "peer_reviews", "departments"
  add_foreign_key "peer_reviews", "institutional_aids"
  add_foreign_key "peer_reviews", "people", column: "reviewer_person_id"
  add_foreign_key "peer_reviews", "project_stages"
  add_foreign_key "person_contacts", "people", on_delete: :cascade
  add_foreign_key "ppi_levels", "people", on_delete: :cascade
  add_foreign_key "project_stages", "legacy_statuses"
  add_foreign_key "project_stages", "people", column: "lead_person_id"
  add_foreign_key "project_stages", "research_areas"
  add_foreign_key "project_stages", "research_projects"
  add_foreign_key "research_projects", "departments"
  add_foreign_key "research_projects", "people", column: "lead_person_id"
  add_foreign_key "research_projects", "research_areas"
  add_foreign_key "scholarships", "departments"
  add_foreign_key "scholarships", "people"
  add_foreign_key "stage_co_investigators", "people"
  add_foreign_key "stage_co_investigators", "project_stages"
  add_foreign_key "stage_extensions", "project_stages"
  add_foreign_key "stage_publications", "project_stages"
  add_foreign_key "ucv_appointments", "people", on_delete: :cascade
  add_foreign_key "user_permissions", "users"
end
