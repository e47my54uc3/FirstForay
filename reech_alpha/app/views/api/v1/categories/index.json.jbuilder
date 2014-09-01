json.status 200
json.categories do
	json.array! entries, :id, :title
end