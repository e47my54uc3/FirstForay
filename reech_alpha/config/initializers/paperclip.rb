Paperclip::Attachment.default_options[:url] = ':s3_domain_url'
if Rails.env.development?
 Paperclip::Attachment.default_options[:path] = '/development' + '/:class/:attachment/:id_partition/:style/:filename' 
# http://reechattachmentstorage.s3.amazonaws.com/user_profiles/pictures/000/000/005/medium/data.txt?1407334787
elsif Rails.env.test?
Paperclip::Attachment.default_options[:path] = '/staging'+ '/:class/:attachment/:id_partition/:style/:filename'
else
  Paperclip::Attachment.default_options[:path] = '/:class/:attachment/:id_partition/:style/:filename'
end

