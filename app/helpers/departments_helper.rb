module DepartmentsHelper
  def department_tree(departments, &block)
    Department.department_tree(departments, &block)
  end

  def parent_department_select_tag(department)
    selected = department&.parent

    # Retrieve the requested parent department
    parent_id = params.dig(:department, :parent_id) || params[:parent_id]
    selected = Department.find_by(id: parent_id) if parent_id.present?

    departments = department ? department.allowed_parents.compact : Department.all
    options = content_tag(:option, '', value: '')

    options << department_tree_options_for_select(departments, selected: selected)
    select_tag 'department[parent_id]', options.html_safe, id: 'department_parent_id'
  end  

  def department_tree_options_for_select(departments, options = {})
    safe_join(department_tree(departments).map do |department, level|
      name_prefix = ('&nbsp;' * 2 * level + '&#187; ').html_safe if level.positive?
      tag_options = { value: department.id, selected: department == options[:selected] }
      tag_options.merge!(yield(department)) if block_given?

      content_tag(options[:tag] || :option, name_prefix.to_s + h(department.name), tag_options)
    end)
  end  

  def department_tree_links(departments, options = {})
    content_tag(:ul, class: 'department-tree') do
      safe_join([
        content_tag(:li, link_to(l(:label_people_all), {})),

        department_tree(departments).map do |department, level|
          name_prefix = ('&nbsp;' * 2 * level + '&#187; ').html_safe if level.positive?
          css_class = 'selected' if @department && department == @department

          content_tag(:li) do
            name_prefix.to_s + link_to(department.name, { department_id: department.id }, class: css_class)
          end
        end
      ].flatten.compact)
    end
  end
end
