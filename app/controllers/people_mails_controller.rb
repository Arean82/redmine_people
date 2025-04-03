class PeopleMailsController < ApplicationController
  def new
    @people = Person.visible.where(id: params[:ids]).reject { |c| c.email.blank? }
    raise ActiveRecord::RecordNotFound if @people.empty?
    
    unless @people.all?(&:send_mail_allowed?)
      deny_access
      return
    end
  end

  def create
    people = Person.visible.where(id: params[:ids])
    raise ActiveRecord::RecordNotFound if people.empty?
    
    unless people.all?(&:send_mail_allowed?)
      deny_access
      return
    end
    
    raise_delivery_errors = ActionMailer::Base.raise_delivery_errors
    ActionMailer::Base.raise_delivery_errors = true
    
    delivered_people = []
    error_people = []
    
    people.each do |person|
      begin  
        params[:message] = mail_macro(person, params[:"message-content"])
        ContactsMailer.bulk_mail(person, params).deliver_now
        delivered_people << person

        note = ContactNote.new(subject: params[:subject], content: params[:message], author: User.current, type_id: Note.note_types[:email])
        person.notes << note
        Attachment.attach_files(note, params[:attachments])    
        render_attachment_warning_if_needed(note) 
      rescue StandardError => e
        error_people << [person, e.message]
      end
    end
    
    flash[:notice] = l(:notice_email_sent, delivered_people.map { |c| "#{c.name} <span class='icon icon-email'>#{c.emails.first}</span>" }.join(', ')).truncate(500) if delivered_people.any?
    flash[:error] = l(:notice_email_error, error_people.map { |e| "#{e[0].name}: #{e[1]}" }.join(', ')).truncate(500) if error_people.any?
    
    ActionMailer::Base.raise_delivery_errors = raise_delivery_errors
    redirect_back fallback_location: { controller: 'people', action: 'index', project_id: @project }
  end  

  def preview_email
    @text = mail_macro(Person.visible.find_by(id: params[:ids].first), params[:"message-content"])
    render partial: 'common/preview'
  end  
end
