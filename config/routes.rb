Rails.application.routes.draw do
  get 'intip_workspaces/index'
  get 'workspaces/index'

  # devise routes
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }

  # rails admin routes
  mount RailsAdmin::Engine => '/secretroom', as: 'rails_admin'

  root 'homepages#index'
  get 'privacy-policy', to: 'homepages#privacy_policy'
  get 'carts', to: 'carts#index'
  get '/hello', to: 'homepages#hello'
  get '/table-data/session/set', to: 'application#submission_set'

  #======------ SETTINGS ------======#
  post '/settings/update', to: 'super_admins#update_settings'

  #======------ DASHBOARDS ------======#
  get   '/dashboards', to: 'dashboards#index'
  get   '/dashboards/counter', to: 'dashboards#counter'
  get   '/dashboards/profile', to: 'dashboards#profile'
  post  '/dashboards/profile/update', to: 'dashboards#update_profile'
  post  '/dashboards/password/update', to: 'dashboards#update_password'

  #======------ SUPER ADMIN ------======#
  get     '/superadmin', to: 'super_admins#index'
  get     '/superadmin/member', to: 'super_admins#list_member'
  get     '/superadmin/member/edit/:id', to: 'super_admins#edit_member', as: 'sa_edit_member'
  post    '/superadmin/member/edit/process', to: 'super_admins#process_update_member'
  get     '/superadmin/member/new', to: 'super_admins#new_member', as: 'sa_new_member'
  post    '/superadmin/member/new/process', to: 'super_admins#process_create_member'
  delete  '/superadmin/member/delete/:id', to: 'super_admins#destroy_member', as: 'sa_destroy_member'
  get     '/superadmin/admin', to: 'super_admins#list_admin'
  get     '/superadmin/admin/edit/:id', to: 'super_admins#edit_admin', as: 'sa_edit_admin'
  post    '/superadmin/admin/edit/process', to: 'super_admins#process_update_admin'
  get     '/superadmin/admin/new', to: 'super_admins#new_admin', as: 'sa_new_admin'
  post    '/superadmin/admin/new/process', to: 'super_admins#process_create_admin'
  delete  '/superadmin/admin/delete/:id', to: 'super_admins#destroy_admin', as: 'sa_destroy_admin'
  get     '/superadmin/validasi', to: 'super_admins#validations'
  get     '/superadmin/validasi/:id', to: 'super_admins#validation_detail', as: 'sa_validation_detail'
  get     '/superadmin/pola-ruang', to: 'super_admins#space_patterns'
  get     '/superadmin/pola-ruang/:id', to: 'super_admins#space_pattern_detail', as: 'sa_space_pattern_detail'
  get     '/superadmin/settings', to: 'super_admins#settings'

  #======------ MEMBER VALIDASI ------======#
  get   '/dashboards/member', to: 'members#index'
  get   '/dashboards/member/validasi', to: 'members#validation'
  get   '/dashboards/member/validasi/submission', to: 'members#validation_submission'
  post  '/dashboards/member/validasi/submission', to: 'members#validation_process_submission'
  get   '/dashboards/member/pola-ruang', to: 'members#space_pattern'
  get   '/dashboards/member/pola-ruang/submission', to: 'members#space_pattern_submission'
  post  '/dashboards/member/pola-ruang/submission', to: 'members#space_pattern_process_submission'
  get   '/dashboards/member/submission/edit/:id', to: 'members#submission_edit', as: 'member_submission_edit'
  get   '/dashboards/member/submission/detail/:id', to: 'members#submission_detail', as: 'member_submission_detail'
  put   '/dashboards/member/submission/detail/:id', to: 'members#prosess_submission_edit', as: 'member_process_submission_edit'

  #======------ ADMIN VALIDASI ------======#
  get     '/dashboards/admin', to: 'admins#index'
  get     '/dashboards/admin/permohonan', to: 'admins#applications'
  get     '/dashboards/admin/permohonan/session/set', to: 'admins#submission_set'
  get     '/dashboards/admin/permohonan/session/approve', to: 'admins#submission_approve'
  delete  '/dashboards/admin/permohonan/session/delete', to: 'admins#submission_delete'
  get     '/dashboards/admin/permohonan/loket', to: 'admins#counter'
  get     '/dashboards/admin/permohonan/loket/ambil/:id', to: 'admins#taken_submission', as: 'admin_taken_submission'
  post    '/dashboards/admin/permohonan/loket/ambil/process', to: 'admins#process_taken_submission', as: 'admin_process_taken_submission'
  get     '/dashboards/admin/permohonan/revisi', to: 'admins#revisions'
  get     '/dashboards/admin/permohonan/revisi/member/:id', to: 'admins#member_revisions', as: 'admin_member_revision'
  post    '/dashboards/admin/permohonan/revisi/member/process', to: 'admins#process_member_revision', as: 'admin_process_member_revision'
  get     '/dashboards/admin/permohonan/setujui/:id', to: 'admins#accept_submission', as: 'admin_accept_submission'
  post    '/dashboards/admin/permohonan/setujui/process', to: 'admins#process_accept_submission', as: 'admin_process_accept_submission'
  get     '/dashboards/admin/permohonan/detail/:id', to: 'admins#detail_submission', as: 'admin_detail_submission'
  delete  '/dashboards/admin/permohonan/delete/:id', to: 'admins#delete_submission', as: 'admin_delete_submission'

  #======------ KASUBSI ------======#
  get '/dashboards/kasubsi', to: 'kasubsis#index'
  get '/dashboards/kasubsi/accept/:id', to: 'kasubsis#accept_submission', as: 'kasubsi_accept_submission'
  get '/dashboards/kasubsi/permohonan', to: 'kasubsis#application_report'
  get '/dashboards/kasubsi/permohonan/detail/:id', to: 'kasubsis#submission_detail', as: 'kasubsi_detail_submission'
  get '/dashboards/kasubsi/permohonan/session/approve', to: 'kasubsis#submission_approve'

  #======------ ADMIN INTIP ------======#
  get     'intip/admin', to: 'intips#index'
  get     'intip/admin/members', to: 'intips#members'
  get     'intip/admin/members/new', to: 'intips#new_member'
  post    'intip/admin/members/create', to: 'intips#create_member'
  get     'intip/admin/members/edit/:id', to: 'intips#edit_member', as: 'intip_admin_members_edit'
  get     'intip/admin/members/detail/:id', to: 'intips#detail_member', as: 'intip_admin_members_detail'
  delete  'intip/admin/members/delete/:id', to: 'intips#delete_member', as: 'intip_admin_members_delete'
  put     'intip/admin/members/edit/process/:id', to: 'intips#process_edit_member', as: 'intip_admin_members_edit_process'
  get     'intip/admin/permohonan', to: 'intips#submissions'
  get     'intip/admin/intip/members', to: 'intips#intip_members'
  get     'intip/admin/intip/members/:id', to: 'intips#intip_members_detail', as: 'intip_admin_intip_members_detail'
  get     'intip/admin/intip/members/:id/permohonan/:workspace_id', to: 'intips#intip_members_permohonan', as: 'intip_admin_intip_members_permohonan'


  #======------ GPS ADMIN ------======#
  get     'gps/admin', to: 'gps#index'
  get     'gps/admin/gps/members', to: 'gps#gps_members'
  get     'gps/admin/gps/members/:id', to: 'gps#gps_members_detail', as: 'gps_admin_gps_members_detail'
  delete  'gps/admin/gps/members/:id/delete/workspace/:workspace_id', to: 'gps#delete_workspace_member', as: 'gps_admin_gps_members_delete_workspace'
  get     'gps/admin/gps/members/:id/permohonan/:workspace_id', to: 'gps#gps_members_permohonan', as: 'gps_admin_gps_members_permohonan'

  get     'gps/admin/permohonan/:id', to: 'gps#detail', as: 'gps_admin_permohonan_detail'

  get     'gps/admin/members', to: 'gps#members'
  get     'gps/admin/members/new', to: 'gps#new_member'
  post    'gps/admin/members/create', to: 'gps#create_member'
  get     'gps/admin/members/edit/:id', to: 'gps#edit_member', as: 'gps_admin_members_edit'
  get     'gps/admin/members/detail/:id', to: 'gps#detail_member', as: 'gps_admin_members_detail'
  delete  'gps/admin/members/delete/:id', to: 'gps#delete_member', as: 'gps_admin_members_delete'
  put     'gps/admin/members/edit/process/:id', to: 'gps#process_edit_member', as: 'gps_admin_members_edit_process'


  #======------ MEMBER INTIP ------======#
  get     'intip/member', to: 'member_intips#index'
  get     'intip/member/permohonan', to: 'member_intips#intip'
  get     'intip/member/permohonan/detail/:id', to: 'member_intips#show', as: 'intips_member_permohonan_detail'
  post    'intip/member/permohonan/action', to: 'member_intips#action'
  get     'intip/member/permohonan/new', to: 'member_intips#new_intip_submission'
  get     'intip/member/permohonan/download', to: 'member_intips#intip_submission'
  post    'intip/member/permohonan/submit', to: 'member_intips#submit_intip_submission'
  post    'intip/member/permohonan/process-data', to: 'member_intips#process_data'
  get     'intips/workspaces', to: 'intip_workspaces#index'
  post    'intips/workspaces', to: 'intip_workspaces#process_create'
  get     'intips/workspaces/create', to: 'intip_workspaces#create'
  get     'intips/workspaces/detail/:id', to: 'intip_workspaces#detail', as: 'intips_member_workspaces_detail'
  delete  'intips/workspaces/delete/:id', to: 'intip_workspaces#delete', as: 'intips_member_workspaces_delete'
  get     'intips/workspaces/:id', to: 'intip_workspaces#show', as: 'intips_member_workspaces_show'
  get     'intips/workspaces/:id/buat-permohonan', to: 'intip_workspaces#new_submission', as: 'intips_member_workspaces_new_submission'
  post    'intips/workspaces/:id/buat-permohonan/process', to: 'intip_workspaces#process_new_submission', as: 'intips_member_workspaces_process_new_submission'
  post    'intips/workspaces/permohonan/process-data', to: 'intip_workspaces#process_data', as: 'intips_member_workspaces_permohonan_process_data'


  #======------ GPS MEMBER ------======#
  get     'gps/member', to: 'member_gps#index'
  get     'gps/member/permohonan', to: 'member_gps#gps'
  get     'gps/member/permohonan/new', to: 'member_gps#new_gps_submission'
  post    'gps/member/permohonan/submit', to: 'member_gps#submit_gps_submission'
  delete  'gps/member/permohonan/delete', to: 'member_gps#delete_gps_submission'
  put     'gps/member/permohonan/sent', to: 'member_gps#sent_gps_submission'
  get     'gps/member/permohonan/:id', to: 'member_gps#detail_gps_submission', as: 'gps_member_permohonan_detail'
  get     'gps/member/permohonan/edit/:id', to: 'member_gps#edit_gps_submission', as: 'gps_member_permohonan_edit'
  put     'gps/member/permohonan/edit/:id', to: 'member_gps#edit_process_gps_submission', as: 'gps_member_permohonan_edit_process'
  post    'gps/member/permohonan/process-data', to: 'member_gps#process_data', as: 'gps_member_permohonan_process_data'
  get     'gps/workspaces', to: 'workspaces#index'
  post    'gps/workspaces', to: 'workspaces#process_create'
  get     'gps/workspaces/create', to: 'workspaces#create'
  get     'gps/workspaces/:id', to: 'workspaces#show', as: 'gps_member_workspaces_show'
  post    'gps/workspaces/:id/process-data', to: 'workspaces#process_data', as: 'gps_member_workspaces_process_data'
  get     'gps/workspaces/detail/:id', to: 'workspaces#detail', as: 'gps_member_workspaces_detail'
  delete  'gps/workspaces/delete/:id', to: 'workspaces#delete', as: 'gps_member_workspaces_delete'
  get     'gps/workspaces/:id/permohonan/:submission_id', to: 'workspaces#detail_submission', as: 'gps_member_workspaces_detail_submission'
  get     'gps/workspaces/:id/permohonan/update/:submission_id', to: 'workspaces#update_submission', as: 'gps_member_workspaces_update_submission'

  get      'gps/workspaces/:id/permohonan/import/set', to: 'workspaces#import_submission', as: 'gps_member_workspaces_import_submission'
  get      'gps/workspaces/:id/permohonan/import/format', to: 'workspaces#format_import_submission', as: 'gps_member_workspaces_format_import_submission'
  post     'gps/workspaces/:id/permohonan/import', to: 'workspaces#process_import_submission', as: 'gps_member_workspaces_process_import_submission'

  get     'gps/workspaces/:id/buat-permohonan', to: 'workspaces#new_submission', as: 'gps_member_workspaces_new_submission'
  post    'gps/workspaces/:id/buat-permohonan/process', to: 'workspaces#process_new_submission', as: 'gps_member_workspaces_process_new_submission'

  get     'gps/member/berkas', to: 'member_gps#completed_gps'
  delete  'gps/member/berkas/delete', to: 'member_gps#delete_completed_gps'

  #======------ API ------======#
  namespace :api do
    namespace :v1 do
      post  'auth/login', to: 'users#login'
      get   'auth/logout', to: 'users#logout'
      post  'auth/register', to: 'users#register'
      put   'auth/change-password', to: 'users#change_password'
      post  'auth/reset-password/sent-code', to: 'users#sent_code'
      get   'auth/reset-password/check-code', to: 'users#check_code'
      post  'auth/reset-password/change', to: 'users#reset_password'

      scope :user do
        get 'role', to: 'users#role'
        get 'profile', to: 'users#profile'
        put 'profile', to: 'users#update_profile'
        get 'working_areas', to: 'working_areas#index'
      end

      scope :notifications do
        get '/', to: 'notifications#index'
        put 'read', to: 'notifications#read'
        get ':id', to: 'notifications#detail'
      end

      scope :submissions do
        get   '/', to: 'members#index'
        get   'recaps', to: 'members#submission_recaps'
        get   'validations', to: 'members#validations'
        post  'validations/create', to: 'members#create_validations'
      end

      scope :sipilot do
        get     '/', to: 'sipilot#index'
        get     'recaps', to: 'sipilot#recaps'
        get     'services', to: 'sipilot#services'
        get     'submissions/all', to: 'sipilot#submissions_all'
        get     'submissions/recaps', to: 'sipilot#submissions_recaps'
        post    'submissions/create', to: 'sipilot#submissions_create'
        put     'submissions/update', to: 'sipilot#submissions_update'
        get     'submissions/:id', to: 'sipilot#submissions_detail'
        get     'submissions/all/download', to: 'sipilot#submissions_download'

        get     'berkas', to: 'sipilot#all_completed_submission'
        delete  'berkas/delete', to: 'sipilot#delete_completed_submission'
        get     'berkas/download', to: 'sipilot#download_completed_submission'
        get     'berkas/:id', to: 'sipilot#detail_completed_submission'
      end

      scope :gps do
        get     '/', to: 'gps#index'
        get     'permohonan-serentak', to: 'gps#concurrent_requests'
        get     'detail-rekapitulasi', to: 'gps#detail_recapitulation'
        get     'permohonan-serentak/all', to: 'gps#list_concurrent_requests'
        get     'permohonan-serentak/:id', to: 'gps#detail_concurrent_requests'
        get     'permohonan-serentak/all/download', to: 'gps#download_concurrent_requests'
        post    'permohonan-serentak/insert', to: 'gps#insert_concurrent_requests'
        put     'permohonan-serentak/update', to: 'gps#update_concurrent_requests'
        put     'permohonan-serentak/sent', to: 'gps#send_concurrent_requests'
        delete  'permohonan-serentak/delete', to: 'gps#delete_concurrent_requests'

        get     'workspaces', to: 'workspaces#index'
        post    'workspaces/create', to: 'workspaces#create'
        get     'workspaces/permohonan/all', to: 'workspaces#list_submissions'
        put     'workspaces/permohonan/sent', to: 'workspaces#sent_submissions'
        put     'workspaces/permohonan/update', to: 'workspaces#update_submissions'
        post    'workspaces/permohonan/create', to: 'workspaces#create_submission'
        delete  'workspaces/permohonan/delete', to: 'workspaces#delete_submissions'
        get     'workspaces/permohonan/detail/:id', to: 'workspaces#detail_submission'
        get     'workspaces/villages', to: 'workspaces#villages'
        post    'workspaces/import/process', to: 'workspaces#process_import_submission'
        get     'workspaces/import/format', to: 'workspaces#format_import_submission'

        get     'berkas', to: 'gps#all_completed_submission'
        delete  'berkas/delete', to: 'gps#delete_completed_submission'
        get     'berkas/download', to: 'gps#download_completed_submission'
        get     'berkas/:id', to: 'gps#detail_completed_submission'
      end

      scope :misc do
        get '/haks', to: 'miscellaneous#haks'
        get '/acts', to: 'miscellaneous#act_fors'
        get '/villages', to: 'miscellaneous#villages'
        get '/sub_districts', to: 'miscellaneous#sub_district'
        get '/districts', to: 'miscellaneous#districts'
        get '/working_areas', to: 'miscellaneous#working_areas'
        get '/alas', to: 'miscellaneous#alas_types'
        get '/certificate-status', to: 'miscellaneous#certificate_status'
      end
    end
  end

  # core api
  scope :api do
    scope :core do
      scope :users do
        get   '/all', to: 'users#index'
        get   '/me', to: 'users#profile'
        post  '/sign-up', to: 'users#sign_up'
        post  '/sign-in', to: 'users#sign_in'
      end
    end
  end
end
