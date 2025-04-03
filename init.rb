require 'redmine_people'

Redmine::Plugin.register :redmine_people do
  name 'Redmine People plugin'
  author 'RedmineCRM'
  description 'This is a plugin for managing Redmine users'
  version '0.2.0'
  url 'http://redminecrm.com/projects/people'
  author_url 'mailto:support@redminecrm.com'

  requires_redmine :version_or_higher => '5.1.0'

  settings default: {
    users_acl: {},
    visibility: ''
  }, partial: 'settings/redmine_people_settings'

  menu :top_menu, :people, { controller: 'people', action: 'index', project_id: nil }, 
       caption: :label_people, if: Proc.new { User.current.allowed_people_to?(:view_people) }

  menu :admin_menu, :people, { controller: 'people_settings', action: 'index' }, 
       caption: :label_people
end
