xml.instruct!
xml.Response do
  xml.Gather(:numDigits => "1", :action => "/api/ivr/?user=#{@user_id}", :method => "get") do
    xml.Say(:voice => "alice", :language => "en-AU") do
      xml.text! "To navigate your address book, press 1."
    end
    xml.Say(:voice => "alice", :language => "en-AU") do
      xml.text! "To text your groups, press 2."
    end
    xml.Say(:voice => "alice", :language => "en-AU") do
      xml.text! "To voice blast your groups, press 3."
    end
  end
end
