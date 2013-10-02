require 'nokogiri'

class ContactsController < ApplicationController

  def index
    @contacts = current_user.contacts
    @groups = current_user.groups
  end

  def new
    @contact = Contact.new
    render layout: false
  end

  def create
    u = current_user.contacts.build(params[:contact])
    unless u.save
      flash[:errors] = u.errors.full_messages
      redirect_to new_contact_path
    else
      redirect_to root_path
    end
  end

  def edit
    @contact = Contact.find(params[:id])
    render layout: false

  end

  def show
    @contact = Contact.find(params[:id])
  end

  def update
    contact = Contact.find(params[:id])
    if contact.update_attributes(params[:contact])
      flash[:notice] = "Successfully Updated!"
      redirect_to root_path
    else

      flash[:errors] = contact.errors.full_messages
      redirect_to edit_contact_path
    end
  end

  def destroy
    Contact.find(params[:id]).destroy
    redirect_to root_path
  end

  def import
    user_info = JSON.parse(RestClient.get user_info_url(google_auth_token))
    contacts_response = RestClient.get google_contacts_url(user_info['email'], google_auth_token)
    @imported_contacts = parse_xml_contacts(contacts_response)
    render :import
  end

  private

  def parse_xml_contacts(contacts_response)
    parsed_contacts = []
    xml_contacts = Nokogiri::XML(contacts_response)
    xml_contacts.css('entry').each do |node|
      phone_number_tags = node.xpath('gd:phoneNumber')
      phone_number_types = phone_number_tags.map { |phone_tag| phone_tag.attr('rel').match(/[^#]\w+$/).to_s.to_sym unless phone_tag.attr('rel').nil? }
      if phone_number_tags[0] != nil && phone_number_types.include?(:mobile)
        contact = { name: node.at_css('title').text }
        phone_numbers = phone_number_tags.map { |phone_tag| phone_tag.inner_text }
        contact.merge!(Hash[phone_number_types.zip(phone_numbers)].delete_if {|k, v| k != :mobile })
        parsed_contacts << contact
      end
    end
    parsed_contacts
  end

end
