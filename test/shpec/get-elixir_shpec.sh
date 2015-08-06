

describe "shpec"
  describe "basic commands"

    it "tests_short_help"
      echo $(pwd)
      message="$(./get-elixir.sh)"
      assert equal "$?" "1"
      #echo "${message}"
      #assert match "$message" "missing\ arguments"
      #assert match "$message" "for\ more\ information."
    end
  end
end