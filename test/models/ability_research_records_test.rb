require "test_helper"

class AbilityResearchRecordsTest < ActiveSupport::TestCase
  test "direction, subdirection and superadmin read research records" do
    %i[director subdirector superadmin].each do |key|
      ability = Ability.new(users(key))

      Ability::RESEARCH_RECORDS.each do |model|
        assert ability.can?(:read, model), "#{key} should read #{model}"
      end
      assert ability.can?(:read, people(:active_engineer))
    end
  end

  test "nobody edits research records" do
    %i[director subdirector superadmin dtic_head dadi_head].each do |key|
      ability = Ability.new(users(key))

      %i[create update destroy].each do |action|
        assert ability.cannot?(action, Person), "#{key} should not #{action} people"
        assert ability.cannot?(action, ResearchProject), "#{key} should not #{action} projects"
      end
    end
  end

  test "dtic head keeps managing content but cannot see research records" do
    ability = Ability.new(users(:dtic_head))

    assert ability.can?(:manage, Call)
    Ability::RESEARCH_RECORDS.each do |model|
      assert ability.cannot?(:read, model), "DTIC head should not read #{model}"
    end
  end

  test "other department heads cannot see research records" do
    ability = Ability.new(users(:dadi_head))

    assert ability.cannot?(:read, Person)
    assert ability.cannot?(:read, ResearchProject)
    assert_empty Person.accessible_by(ability)
  end
end
