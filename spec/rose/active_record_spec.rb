require 'spec_helper'
require 'rose/active_record'

module RoseActiveRecordSpecs
  class Person < ActiveRecord::Base
    attr_protected :password
  end

  class Admin < Person
  end

  class Post < ActiveRecord::Base
    has_many :comments
  end

  class Comment < ActiveRecord::Base
    belongs_to :post
    belongs_to :author, :class_name => "Person"
  end

  class Subject < ActiveRecord::Base
    has_many :tests
  end

  class Test < ActiveRecord::Base
    belongs_to :subject
    belongs_to :student, :class_name => "Person"
  end

  describe Rose, "ActiveRecord adapter" do
    before(:suite) do
      # ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/log/test.log")
      ActiveRecord::Migration.verbose = false
      ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
      load(File.dirname(__FILE__) + "/../db/schema.rb")

      person_1 = Person.create(:name => "Person #1")
      person_2 = Person.create(:name => "Person #2")

      post_1 = Post.create(:title => "Post #1", :guid => "P1")
      post_1.comments.create(:author => person_1)
      post_1.comments.create(:author => person_2)
      post_2 = Post.create(:title => "Post #2", :guid => "P2")
      post_2.comments.create(:author => person_2)
    end

    describe "make report" do
      before do
        Post.rose(:post_comments) do
          rows do
            column("Post", &:title)
            column("Comments") { |item| item.comments.size }
          end
        end

        Post.rose(:post_comments_sorted_asc) do
          rows do
            column("Post", &:title)
            column("Comments") { |item| item.comments.size }
          end
          sort("Comments", :ascending)
        end

        Post.rose(:post_comments_sorted_desc) do
          rows do
            column("Post", &:title)
            column("Comments") { |item| item.comments.size }
          end
          sort("Comments", :descending)
        end
      end

      it "should report on posts' comments" do
        Post.rose_for(:post_comments).should match_table <<-eo_table.gsub(%r{^        }, '')
        +--------------------+
        |  Post   | Comments |
        +--------------------+
        | Post #1 | 2        |
        | Post #2 | 1        |
        +--------------------+
        eo_table
      end

      it "should order by comments size" do
        Post.rose_for(:post_comments_sorted_asc).should match_table <<-eo_table.gsub(%r{^        }, '')
        +--------------------+
        |  Post   | Comments |
        +--------------------+
        | Post #2 | 1        |
        | Post #1 | 2        |
        +--------------------+
        eo_table

        Post.rose_for(:post_comments_sorted_desc).should match_table <<-eo_table.gsub(%r{^        }, '')
        +--------------------+
        |  Post   | Comments |
        +--------------------+
        | Post #1 | 2        |
        | Post #2 | 1        |
        +--------------------+
        eo_table
      end

      it "should report only posts with #2" do
        Post.rose_for(:post_comments, :conditions => ["title like ?", "%#2%"]).should match_table <<-eo_table.gsub(%r{^        }, '')
        +--------------------+
        |  Post   | Comments |
        +--------------------+
        | Post #2 | 1        |
        +--------------------+
        eo_table
      end
    end

    describe "make report with sigma" do
      before do
        Comment.rose(:author_comments) do
          rows do
            column("Author") { |item| item.author.name }
            column("Posts") { |item| item.post.title }
            column("Comments") { |item| true }
          end
          summary("Author") do
            column("Posts") { |posts| posts.join(", ") }
            column("Comments") { |comments| comments.size }
          end
        end
      end

      it "should get authors and their comments" do
        Comment.rose_for(:author_comments).should match_table <<-eo_table.gsub(%r{^        }, '')
        +-----------------------------------------+
        |  Author   |      Posts       | Comments |
        +-----------------------------------------+
        | Person #1 | Post #1          |        1 |
        | Person #2 | Post #1, Post #2 |        2 |
        +-----------------------------------------+
        eo_table
      end
    end

    describe "make report with pivot" do
      it "should make report with pivot" do
        elisa = Person.create(:name => "Elisa")
        mary = Person.create(:name => "Mary")
        english = Subject.create(:name => "English")
        math = Subject.create(:name => "Math")
        science = Subject.create(:name => "Science")
        art = Subject.create(:name => "Art")
        history = Subject.create(:name => "History")
        french = Subject.create(:name => "French")

        Test.create(:student => elisa, :subject => english, :score => 87, :created_at => Date.parse('January 2010'))
        Test.create(:student => elisa, :subject => math, :score => 65, :created_at => Date.parse('January 2010'))
        Test.create(:student => elisa, :subject => science, :score => 58, :created_at => Date.parse('January 2010'))
        Test.create(:student => elisa, :subject => art, :score => 89, :created_at => Date.parse('January 2010'))
        Test.create(:student => elisa, :subject => history, :score => 81, :created_at => Date.parse('January 2010'))
        Test.create(:student => elisa, :subject => french, :score => 62, :created_at => Date.parse('January 2010'))

        Test.create(:student => elisa, :subject => english, :score => 51, :created_at => Date.parse('February 2010'))
        Test.create(:student => elisa, :subject => math, :score => 72, :created_at => Date.parse('February 2010'))
        Test.create(:student => elisa, :subject => science, :score => 89, :created_at => Date.parse('February 2010'))
        Test.create(:student => elisa, :subject => art, :score => 83, :created_at => Date.parse('February 2010'))
        Test.create(:student => elisa, :subject => history, :score => 84, :created_at => Date.parse('February 2010'))
        Test.create(:student => elisa, :subject => french, :score => 57, :created_at => Date.parse('February 2010'))

        Test.create(:student => elisa, :subject => english, :score => 41, :created_at => Date.parse('March 2010'))
        Test.create(:student => elisa, :subject => math, :score => 71, :created_at => Date.parse('March 2010'))
        Test.create(:student => elisa, :subject => science, :score => 41, :created_at => Date.parse('March 2010'))
        Test.create(:student => elisa, :subject => art, :score => 92, :created_at => Date.parse('March 2010'))
        Test.create(:student => elisa, :subject => history, :score => 91, :created_at => Date.parse('March 2010'))
        Test.create(:student => elisa, :subject => french, :score => 56, :created_at => Date.parse('March 2010'))

        Test.create(:student => mary, :subject => english, :score => 87, :created_at => Date.parse('January 2010'))
        Test.create(:student => mary, :subject => math, :score => 53, :created_at => Date.parse('January 2010'))
        Test.create(:student => mary, :subject => science, :score => 35, :created_at => Date.parse('January 2010'))
        Test.create(:student => mary, :subject => art, :score => 61, :created_at => Date.parse('January 2010'))
        Test.create(:student => mary, :subject => history, :score => 58, :created_at => Date.parse('January 2010'))
        Test.create(:student => mary, :subject => french, :score => 92, :created_at => Date.parse('January 2010'))

        Test.create(:student => mary, :subject => english, :score => 68, :created_at => Date.parse('February 2010'))
        Test.create(:student => mary, :subject => math, :score => 54, :created_at => Date.parse('February 2010'))
        Test.create(:student => mary, :subject => science, :score => 56, :created_at => Date.parse('February 2010'))
        Test.create(:student => mary, :subject => art, :score => 59, :created_at => Date.parse('February 2010'))
        Test.create(:student => mary, :subject => history, :score => 61, :created_at => Date.parse('February 2010'))
        Test.create(:student => mary, :subject => french, :score => 93, :created_at => Date.parse('February 2010'))

        Test.create(:student => mary, :subject => english, :score => 41, :created_at => Date.parse('March 2010'))
        Test.create(:student => mary, :subject => math, :score => 35, :created_at => Date.parse('March 2010'))
        Test.create(:student => mary, :subject => science, :score => 41, :created_at => Date.parse('March 2010'))
        Test.create(:student => mary, :subject => art, :score => 48, :created_at => Date.parse('March 2010'))
        Test.create(:student => mary, :subject => history, :score => 67, :created_at => Date.parse('March 2010'))
        Test.create(:student => mary, :subject => french, :score => 90, :created_at => Date.parse('March 2010'))

        Test.rose(:scores) do
          rows do
            column("Month") { |test| I18n.l(test.created_at, :format => :short) }
            column("Subject") { |test| test.subject.name }
            column("Student") { |test| test.student.name }
            column(:score => "Score")
          end
          pivot("Month", "Subject") do |matching_rows|
            matching_rows.map(&:Score).map(&:to_f).sum
          end
        end

        Test.rose_for(:scores).should match_table <<-eo_table.gsub(%r{^        }, '')
        +---------------------------------------------------------------------+
        |    Month     |  Art  | Science | English | French | Math  | History |
        +---------------------------------------------------------------------+
        | 01 Jan 00:00 | 150.0 |    93.0 |   174.0 |  154.0 | 118.0 |   139.0 |
        | 01 Feb 00:00 | 142.0 |   145.0 |   119.0 |  150.0 | 126.0 |   145.0 |
        | 01 Mar 00:00 | 140.0 |    82.0 |    82.0 |  146.0 | 106.0 |   158.0 |
        +---------------------------------------------------------------------+
        eo_table
      end
    end

    describe "run report" do
      before do
        Comment.rose(:author_comments) do
          rows do
            column("Author") { |item| item.author.name }
            column("Posts") { |item| item.post.title }
            column("Comments") { |item| item.destroy }
          end
        end
      end

      it "should run report within transaction" do
        all_sizes = lambda { [Person.count, Post.count, Comment.count] }

        lambda {
          Comment.rose_for(:author_comments)
        }.should_not change(all_sizes, :call)
      end
    end

    describe "import report" do
      before do
        Post.rose(:with_update) {
          rows do
            identity(:guid => "ID")
            column("Title", &:title)
            column("Comments") { |item| item.comments.size }
          end

          sort("Comments", :descending)

          roots do
            find do |items, idy|
              items.find { |item| item.guid == idy }
            end
            update do |record, updates|
              record.update_attribute(:title, updates["Title"])
            end
          end
        }

        @post_3 = Post.create(:title => "Post #3", :guid => "P3")
        @post_4 = Post.create(:title => "Post #4", :guid => "P4")
      end

      after do
        @post_3.destroy; @post_4.destroy
      end

      it "should update report" do
        Post.root_for(:with_update, {
          :with => {
            "P3" => { "Title" => "Third Post", "something" => "else" },
            "P4" => { "Title" => "Fourth Post" }
          }
        }).should match_table <<-eo_table.gsub(%r{^        }, '')
        +-----------------------------+
        | ID |    Title    | Comments |
        +-----------------------------+
        | P1 | Post #1     | 2        |
        | P2 | Post #2     | 1        |
        | P4 | Fourth Post | 0        |
        | P3 | Third Post  | 0        |
        +-----------------------------+
        eo_table

        Post.all.map(&:title).should == ["Post #1", "Post #2", "Third Post", "Fourth Post"]
      end

      it "should update report with conditions" do
        Post.root_for(:with_update, {
          :with => {
            "P3" => { "Title" => "Third Post", "something" => "else" },
            "P4" => { "Title" => "Fourth Post" }
          }
        }, { :conditions => ["title like ?", "%#3%"] }).should match_table <<-eo_table.gsub(%r{^        }, '')
        +----------------------------+
        | ID |   Title    | Comments |
        +----------------------------+
        | P3 | Third Post | 0        |
        +----------------------------+
        eo_table

        Post.all.map(&:title).should == ["Post #1", "Post #2", "Third Post", "Post #4"]
      end

      it "should update report from CSV" do
        Post.root_for(:with_update, {
          :with => "spec/examples/update_posts.csv"
        }).should match_table <<-eo_table.gsub(%r{^        }, '')
        +-----------------------------+
        | ID |    Title    | Comments |
        +-----------------------------+
        | P1 | Post #1     | 2        |
        | P2 | Post #2     | 1        |
        | P4 | Fourth Post | 0        |
        | P3 | Third Post  | 0        |
        +-----------------------------+
        eo_table

        Post.all.map(&:title).should == ["Post #1", "Post #2", "Third Post", "Fourth Post"]
      end
    end
    
    describe "preview import report" do
      before do
        Post.rose(:for_import) {
          rows do
            identity(:guid => "ID")
            column("Title", &:title)
            column("Comments") { |item| item.comments.size }
          end
    
          sort("Comments", :descending)
    
          roots do
            find do |items, idy|
              items.find { |item| item.guid == idy }
            end
            preview_update do |record, updates|
              record.title = updates["Title"]
            end
            update { raise Exception, "not me!" }
          end
        }
      end
    
      it "should preview changes" do
        Post.root_for(:for_import, {
          :with => {
            "P1" => { "Title" => "First Post", "something" => "else" },
            "P2" => { "Title" => "Second Post" }
          },
          :preview => true
        }).should match_table <<-eo_table.gsub(%r{^        }, '')
        +-----------------------------+
        | ID |    Title    | Comments |
        +-----------------------------+
        | P1 | First Post  | 2        |
        | P2 | Second Post | 1        |
        +-----------------------------+
        eo_table
    
        Post.all.map(&:title).should == ["Post #1", "Post #2"]
      end
    end
    
    describe "create import report" do
      before do
        Post.rose(:for_create) {
          rows do
            identity(:guid => "ID")
            column("Title", &:title)
            column("Comments") { |item| item.comments.size }
          end
    
          sort("Comments", :descending)
    
          roots do
            find do |items, idy|
              items.find { |item| item.guid == idy }
            end
            preview_create do |idy, updates|
              post = Post.new(:guid => idy)
              post.title = updates["Title"]
              post
            end
            create do |idy, updates|
              post = create_previewer.call(idy, updates)
              post.save!
              post
            end
          end
        }
      end
      
      it "should preview create" do
        Post.root_for(:for_create, {
          :with => {
            "P3" => { "Title" => "Post #3" }
          },
          :preview => true
        }).should match_table <<-eo_table.gsub(%r{^        }, '')
        +-------------------------+
        | ID |  Title  | Comments |
        +-------------------------+
        | P1 | Post #1 | 2        |
        | P2 | Post #2 | 1        |
        | P3 | Post #3 | 0        |
        +-------------------------+
        eo_table
      end
      
      it "should create" do
        Post.root_for(:for_create, {
          :with => {
            "P3" => { "Title" => "Post #3" }
          }
        }).should match_table <<-eo_table.gsub(%r{^        }, '')
        +-------------------------+
        | ID |  Title  | Comments |
        +-------------------------+
        | P1 | Post #1 | 2        |
        | P2 | Post #2 | 1        |
        | P3 | Post #3 | 0        |
        +-------------------------+
        eo_table
        
        Post.last.title.should == "Post #3"
        
        Post.last.destroy
      end
    end
  end

end