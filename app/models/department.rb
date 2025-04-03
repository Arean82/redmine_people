class Department < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :head, class_name: 'Person', foreign_key: 'head_id'
  has_many :people, -> { distinct }, dependent: :nullify

  acts_as_nested_set order: 'name', dependent: :destroy
  acts_as_attachable_global

  validates :name, presence: true, uniqueness: true

  safe_attributes 'name', 'background', 'parent_id', 'head_id'

  def to_s
    name
  end

  # Yields the given block for each department with its level in the tree
  def self.department_tree(departments)
    ancestors = []
    departments.sort_by(&:lft).each do |department|
      while ancestors.any? && !department.is_descendant_of?(ancestors.last)
        ancestors.pop
      end
      yield department, ancestors.size
      ancestors << department
    end
  end  

  def css_classes
    classes = ['project']
    classes << 'root' if root?
    classes << 'child' if child?
    classes << (leaf? ? 'leaf' : 'parent')
    classes.join(' ')
  end

  def allowed_parents
    @allowed_parents ||= begin
      all_departments = Department.where.not(id: self_and_descendants.ids)
      all_departments += [parent] if parent && !all_departments.include?(parent)
      all_departments << nil
      all_departments
    end
  end  
end
