require_relative('selenium_java_generator.rb')


# Command input


def check_user_input(input) 
    return input != nil && input.length > 0
end


puts "Welcome to <Selenium Java Generator>\nPlease enter class name ex: { Main } without .java!"
answer_java_class_name = gets.chomp
if check_user_input(answer_java_class_name)
    $java_class_name = answer_java_class_name
    puts "input save !"
end

puts "Do you want to ignore some strings?\n(type [y]) | (enter for ignore !)"
answer_strings = gets.chomp

if answer_strings === 'y'
    puts "Please enter the strings or chars followed by (,) ex: { blank,target,https:// ....}"
    strings_not_include = gets.chomp
    if check_user_input(strings_not_include)
        $array_rules_not_include =  strings_not_include.split(",")
        puts "input save !"
        puts $array_rules_not_include
    else
        puts "Unable to proccess your input!"
    end
end

puts "Do you want to ignore some special chars by regex pattern? current defualt #{$special_char_to_match}\n(type [y]) | (enter for ignore !)"
answer_chars = gets.chomp

if answer_chars === 'y'
    puts "Please enter the REGEX pattern"
    _special_char_to_match = gets.chomp
    if check_user_input(_special_char_to_match)
        $special_char_to_match = Regexp.escape(_special_char_to_match)
        puts "input save !"
    else
        puts "Unable to proccess your input!"
    end
end

puts "HTML source? enter (url/file)"
answer_html_source = gets.chomp
if check_user_input(answer_html_source)
    if answer_html_source === 'url'
        puts "enter the url"
        SeleniumJavaGenerator.read_web_page_url(gets.chomp)
    elsif answer_html_source == 'file'
        puts "enter the name with extension ex: {index.html}"
        SeleniumJavaGenerator.read_web_page_file(gets.chomp)
    end
else
    puts "Unable to proccess your input!"
end