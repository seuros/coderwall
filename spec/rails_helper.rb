require 'spec_helper.rb'

Team.__elasticsearch__.create_index!
#add other models here that need indexing