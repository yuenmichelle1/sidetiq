require_relative 'helper'

class TestLockMetaData < Sidetiq::TestCase
  def new_without_params
    md = Sidetiq::Lock::MetaData.new

    assert_nil md.owner
    assert_nil md.timestamp
    assert_nil md.key
  end

  def new_with_empty_hash
    md = Sidetiq::Lock::MetaData.new({})

    assert_nil md.owner
    assert_nil md.timestamp
    assert_nil md.key
  end

  def test_from_json
    json = { timestamp: 42, owner: "me", key: "foobar" }.to_json
    md = Sidetiq::Lock::MetaData.from_json(json)

    assert_equal 42, md.timestamp
    assert_equal "me", md.owner
    assert_equal "foobar", md.key
  end

  def test_from_json_with_empty_string_json
    md = Sidetiq::Lock::MetaData.from_json(nil)

    assert_nil md.owner
    assert_nil md.timestamp
    assert_nil md.key
  end

  def test_from_json_with_nil_json
    md = Sidetiq::Lock::MetaData.from_json("")

    assert_nil md.owner
    assert_nil md.timestamp
    assert_nil md.key
  end

  def test_from_json_with_malformed_json
    Sidetiq::Lock::MetaData.expects(:handle_exception).once

    md = Sidetiq::Lock::MetaData.from_json('invalid')

    assert_nil md.owner
    assert_nil md.timestamp
    assert_nil md.key
  end

  def test_for_new_lock
    md = Sidetiq::Lock::MetaData.for_new_lock("baz")

    assert_equal Sidetiq::Lock::MetaData::OWNER, md.owner
    assert_equal "baz", md.key

    assert md.timestamp > 0
    assert md.timestamp < Time.now.to_f
  end

  def test_to_json
    md = Sidetiq::Lock::MetaData.new(timestamp: 42, owner: "me", key: "foobar")

    assert_equal '{"owner":"me","timestamp":42,"key":"foobar"}', md.to_json
  end

  def test_to_s
    md = Sidetiq::Lock::MetaData.new(timestamp: 42, owner: "me", key: "foobar")

    assert_equal "Sidetiq::Lock on foobar set at 42 by me", md.to_s
  end
end

