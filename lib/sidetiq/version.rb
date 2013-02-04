module Sidetiq
  # Public: Sidetiq version namespace.
  module VERSION
    # Public: Sidetiq major version number.
    MAJOR = 0

    # Public: Sidetiq minor version number.
    MINOR = 1

    # Public: Sidetiq patch level.
    PATCH = 4

    # Public: String representation of the current Sidetiq version.
    STRING = [MAJOR, MINOR, PATCH].compact.join('.')
  end
end

