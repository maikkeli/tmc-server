# frozen_string_literal: true

require 'spec_helper'

feature 'Admin sets expiredate to course templates', feature: true do
  include IntegrationTestActions

  before :each do
    @organization = FactoryBot.create :accepted_organization, slug: 'slug'
    @user = FactoryBot.create :user, password: 'foobar'
    @admin = FactoryBot.create :admin, password: 'xooxer'
    @teacher = FactoryBot.create :user, password: 'xooxer'
    Teachership.create! user: @teacher, organization: @organization

    @ct = FactoryBot.create :course_template, title: 'Template 1'
    @ct_expired_visible = FactoryBot.create :course_template, title: 'Template 2', expires_at: Time.now - 1.day
    @ct_non_expired_visible = FactoryBot.create :course_template, title: 'Template 3', expires_at: Time.now + 1.day, hidden: false
    @ct_expired_hidden = FactoryBot.create :course_template, title: 'Template 4', expires_at: Time.now - 1.day, hidden: true
    @ct_non_expired_hidden = FactoryBot.create :course_template, title: 'Template 5', expires_at: Time.now + 1.day, hidden: true

    visit '/'
  end

  scenario 'Admin succeeds at setting expiredate' do
    log_in_as(@admin.email, 'xooxer')
    visit('/course_templates')

    find('tr', text: 'Template 2').click_link('Edit')

    fill_in 'course_template_expires_at', with: '2020-01-01'
    click_button 'Update Course template'

    expect(page).to have_content('01.01.2020')
  end

  scenario 'Admin succeeds at toggling between hidden and non-hidden' do
    log_in_as(@admin.email, 'xooxer')
    visit('/course_templates')

    find('tr', text: 'Template 2').click_link('hide')
    expect(find('tr', text: 'Template 2')).to have_content('unhide')
    find('tr', text: 'Template 2').click_link('unhide')
    expect(find('tr', text: 'Template 2')).to have_content('hide')
  end

  scenario "Teacher doesn't see expired or hidden course templates" do
    log_in_as(@teacher.email, 'xooxer')
    visit('/org/slug/course_templates')

    expect(page).to have_content('Template 1')
    expect(page).not_to have_content('Template 2')
    expect(page).to have_content('Template 3')
    expect(page).not_to have_content('Template 4')
    expect(page).not_to have_content('Template 5')
  end

  scenario "Teacher can't create course from expired template" do
    log_in_as(@teacher.email, 'xooxer')
    visit("/setup/slug/course/new/#{@ct_expired_visible.id}")
    expect(page).to have_content('Forbidden')
  end

  scenario "Teacher can't create course from hidden template" do
    log_in_as(@teacher.email, 'xooxer')
    visit("/setup/slug/course/new/#{@ct_expired_visible.id}")
    expect(page).to have_content('Forbidden')
  end
end
