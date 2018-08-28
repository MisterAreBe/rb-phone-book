require 'sanitize'

def clean(str)
    og = str
    str = Sanitize.clean(str)
    unless og == str
        return false
    end
    true
end