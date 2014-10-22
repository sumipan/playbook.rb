# encoding: utf-8

require 'minitest/autorun'
require 'playbook'

describe Playbook do
	before do
		@raw_text0 = <<RAW_TEXT
これはサンプルです。
このような書き方でシナリオを記述してください。

```book
scene: シーン1
scenario: すやすやイルカが眠っている
scenario: すやすやイルカに猫が近づく
scene: シーン2
scenario: すやすやイルカが目を覚ます
```

```book
scene: シーン3
scenario: すやすやイルカが眠っている
scenario: すやすやイルカに犬が近づく
scene: シーン4
scenario: すやすやイルカが眠そうにしている
```

RAW_TEXT

		@raw_text1 = <<RAW_TEXT
これはサンプルです。
このような書き方でシナリオを記述してください。

```book
chapter: 章前
scene: シーン1
scenario: すやすやイルカが眠っている
scenario: すやすやイルカに猫が近づく
scene: シーン2
scenario: すやすやイルカが目を覚ます
```

```book
chapter: 第一章
scene: シーン3
scenario: すやすやイルカが眠っている
scenario: すやすやイルカに犬が近づく
scene: シーン4
scenario: すやすやイルカが眠そうにしている
```

RAW_TEXT

		@raw_text2 = <<RAW_TEXT
これはサンプルです。
このような書き方でシナリオを記述してください。

```book
chapter: 第二章
scene: シーン4
scenario: すやすやイルカは眠ってしまった
chapter: 終章
scene: シーン5
scenario: すやすやイルカが眠っている
scenario: すやすやイルカに猫が近づく
scenario: すやすやイルカがびっくりして飛び起きた
```
RAW_TEXT
	end

	it "has no chapter context" do

		playbook = Playbook.parse(@raw_text0)
		playbook.must_be_instance_of Playbook::Book
		playbook.chapters.size.must_equal 1

		chapter = playbook.chapters.first
		chapter.must_be_instance_of Playbook::Chapter

		chapter.scenes.each do |scene|
			scene.name.must_match(/^シーン\d$/)

			scene.scenarios.each do |scenario|
				scenario.must_be_instance_of Playbook::Scenario
				scenario.text.must_match(/^すやすやイルカ/)
			end
		end

		chapter.scenes.size.must_equal 4
		scene = chapter.scenes.select{|s| s.name == 'シーン2' }.first
		scene.scenarios.size.must_equal 1

		puts playbook.to_s
	end

	it "has chapterized" do

		playbook = Playbook::Book.new
		playbook.register_index([
			'章前',
			'第一章',
			'第二章',
			'終章'
		])

		playbook.merge(Playbook.parse(@raw_text1))
		playbook.must_be_instance_of Playbook::Book
		playbook.chapters.size.must_equal 4

		chapter = playbook.chapters.first
		chapter.must_be_instance_of Playbook::Chapter

		chapter.scenes.each do |scene|
			scene.name.must_match(/^シーン\d$/)

			scene.scenarios.each do |scenario|
				scenario.must_be_instance_of Playbook::Scenario
				scenario.text.must_match(/^すやすやイルカ/)
			end
		end

		chapter.scenes.size.must_equal 2
		scene = chapter.scenes.select{|s| s.name == 'シーン2' }.first
		scene.scenarios.size.must_equal 1

		puts playbook.to_s
	end

	it "" do

		playbook = Playbook.parse(@raw_text1)
		copy = playbook.merge(Playbook.parse(@raw_text2))
		copy.must_equal playbook

		puts playbook.to_s
	end
end
