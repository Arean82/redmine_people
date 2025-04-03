class Person < User
  unloadable
  self.inheritance_column = :_type_disabled

  belongs_to :department

  include Redmine::SafeAttributes

  GENDERS = [[l(:label_people_male), 0], [l(:label_people_female), 1]]

  scope :in_department, ->(department) { where("department_id = ? AND type = ?", process_department_id(department), "User") } 

  scope :not_in_department, ->(department) { where("(#{User.table_name}.department_id != ?) OR (#{User.table_name}.department_id IS NULL)", 
                                                    process_department_id(department)) }

  scope :search_by_name, ->(search) { where("LOWER(#{Person.table_name}.firstname) LIKE :q OR 
                                             LOWER(#{Person.table_name}.lastname) LIKE :q OR 
                                             LOWER(#{Person.table_name}.middlename) LIKE :q OR 
                                             LOWER(#{Person.table_name}.login) LIKE :q OR 
                                             LOWER(#{Person.table_name}.mail) LIKE :q", 
                                             q: "#{search.downcase}%") }

  validates :firstname, uniqueness: { scope: [:lastname, :middlename] }

  safe_attributes 'phone', 
                  'address',
                  'skype',
                  'birthday',
                  'job_title',
                  'company',
                  'middlename',
                  'gender',
                  'twitter',
                  'facebook',
                  'linkedin',
                  'department_id',
                  'background',
                  'appearance_date'

  def phones
    phone.present? ? phone.split(/, */) : []
  end  

  def type
    'User'
  end

  def email
    mail
  end

  def project
    nil
  end

  def next_birthday
    return if birthday.blank?

    year = Date.today.year
    birthday_this_year = birthday.change(year: year)

    if birthday_this_year < Date.today
      year += 1
    end

    # Adjust for leap year if necessary
    mmdd = birthday.strftime('%m%d')
    mmdd = '0301' if mmdd == '0229' && !Date.new(year).leap?

    Date.parse("#{year}#{mmdd}")
  end

  def self.next_birthdays(limit = 10)
    where.not(birthday: nil).sort_by(&:next_birthday).first(limit)
  end

  def age
    return nil if birthday.blank?

    now = Time.current
    age = now.year - birthday.year
    age -= 1 if birthday.change(year: now.year) > now
    age
  end

  def editable_by?(usr, prj=nil)
    usr && (usr.allowed_to?(:edit_people, prj) || (self == usr && usr.allowed_to?(:edit_own_profile, prj)))
  end

  def visible?(usr = nil)
    true
  end

  def attachments_visible?(user = User.current)
    true
  end

  private

  def self.process_department_id(department)
    department.is_a?(Department) ? department.id : department.to_i
  end
end
