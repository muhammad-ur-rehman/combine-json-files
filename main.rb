require 'json'

FILE_NAMES = %w[object1 object2 object3].freeze
result_array = []

def read_json_file(file_name)
  JSON.parse(File.read("./#{file_name}.json"))
end

def write_json_file(content)
  File.write('result.json', JSON.unparse(content), mode: 'w')
end

def deep_set(main_hash, current_record, path)
  main_hash_record = main_hash.dig(*path)
  return if main_hash_record.nil?

  main_hash_record['value'] = (main_hash_record.dig('value').to_i + current_record['value'].to_i).to_s
  main_hash_record['children'] = current_record['children'] unless current_record['children'].nil? || current_record['children'].empty?
end

def recursive_main(main_hash, current_hash, path)
  current_hash_record = current_hash.dig(*path)
  if current_hash_record['children'].nil? || main_hash.dig(*path).nil?
    return deep_set(main_hash, current_hash_record, path)
  elsif current_hash_record['children'].empty? || main_hash.dig(*path)['children'].empty?
    return deep_set(main_hash, current_hash_record, path)
  end

  current_hash_record['children'].each_with_index do |x, i|
    current_path = path.clone.push('children').push(i)
    recursive_main(main_hash, current_hash, current_path)
  end
end

result_array = read_json_file(FILE_NAMES[0])
FILE_NAMES.each_with_index do |name, i|
  next if i.zero?

  current_file_hash = read_json_file(name)
  current_file_hash.each_with_index do |record, index|
    recursive_main(result_array, current_file_hash, [index])
  end
end

write_json_file(result_array)
puts result_array
