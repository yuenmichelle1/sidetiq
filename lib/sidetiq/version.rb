module Sidetiq
  # Public: Sidetiq version namespace.
  module VERSION
    # Public: Sidetiq major version number.
    MAJOR = 0

    # Public: Sidetiq minor version number.
    MINOR = 4

    # Public: Sidetiq patch level.
    PATCH = 0

    # Public: Sidetiq version suffix.
    SUFFIX = 'rc4'

    # Public: String representation of the current Sidetiq version.
    STRING = [MAJOR, MINOR, PATCH, SUFFIX].compact.join('.')
  end
end

