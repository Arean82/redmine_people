module PeopleHelper
  def birthday_date(person)
    return unless person&.birthday

    if person.birthday.today?
      "#{l(:label_today).capitalize} (#{person.age.to_i + 1})"
    else
      "#{person.birthday.day} #{t('date.month_names')[person.birthday.month]} (#{person.age.to_i + 1})"
    end
  end

  def people_principals_check_box_tags(name, principals)
    safe_join(principals.map do |principal|
      label_tag(nil) do
        check_box_tag(name, principal.id, false, id: nil) +
          " #{principal.is_a?(Group) ? l(:label_group) + ': ' + principal.to_s : principal}"
      end
    end, "\n")
  end

  def person_to_vcard(person)
    return unless person

    card = Vcard::Vcard::Maker.make2 do |maker|
      maker.add_name do |name|
        name.given = person.firstname.to_s
        name.family = person.lastname.to_s
        name.additional = person.middlename.to_s
      end

      maker.add_addr do |addr|
        addr.preferred = true
        addr.street = person.address.to_s.gsub("\r\n", ' ').gsub("\n", ' ')
      end

      maker.title = person.job_title.to_s
      maker.org = person.company.to_s
      maker.birthday = person.birthday.to_date if person.birthday.present?
      maker.add_note(person.background.to_s.gsub("\r\n", ' ').gsub("\n", ' '))

      person.phones.each { |phone| maker.add_tel(phone) }
      maker.add_email(person.email) if person.email.present?
    end

    if person.avatar&.readable?
      avatar_data = Base64.strict_encode64(File.binread(person.avatar.diskfile))
      photo_vcard = "PHOTO;BASE64:\n " + avatar_data.scan(/.{1,76}/).join("\n ") + "\nEND:VCARD"
      card = card.encode.sub("END:VCARD", photo_vcard)
    end

    card.to_s
  end
end
