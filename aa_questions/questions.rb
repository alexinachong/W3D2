require 'sqlite3'
require 'singleton'
require 'byebug'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
  attr_accessor :fname, :lname
  attr_reader :id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        id
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil if !id
    User.new(data.first)
  end

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        id, fname, lname
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    data.map { |datum| User.new(datum) }
  end


  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise "#{self} already exists!" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} doesn't exist!" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end

  def authored_questions
    authored = Question.find_by_assoc_author(@id)
    # raise "#{self} doesn't exist!" unless authored
    # data = QuestionsDatabase.instance.execute(<<-SQL, question.assoc_author)
    #   SELECT
    #     *
    #   FROM
    #     data
    #   WHERE
    #     assoc_author = ?
    # SQL
    # data.map { |datum| User.new(datum) }
  end

  def authored_replies
    authored = Reply.find_by_user_id(@id)
  end
end

class Question
  attr_accessor :title, :body, :assoc_author
  attr_reader :id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil if !id

    Question.new(data.first)
  end

  def self.find_by_assoc_author(assoc_author)
    data = QuestionsDatabase.instance.execute(<<-SQL, assoc_author)
      SELECT
        *
      FROM
        questions
      WHERE
        assoc_author = ?
    SQL
    return nil if data.length == 0
    data.map { |datum| Question.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @assoc_author = options['assoc_author']
  end

  def create
    raise "#{self} already exists!!" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @assoc_author)
      INSERT INTO
        questions (title, body, assoc_author)
      VALUES
        (?, ?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} doesn't exist" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @assoc_author, @id)
      UPDATE
        questions
      SET
        title = ?, body = ?, assoc_author = ?
      WHERE
        id = ?
    SQL
  end

  def replies
    replies = Reply.find_by_question_id(@id)
  end

end


class Reply
  attr_accessor :body, :subject_id, :parent_id, :user_id
  attr_reader :id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil if !id
    Reply.new(data.first)
  end

  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil if data.length == 0

    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(subject_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, subject_id)
      SELECT
        *
      FROM
        replies
      WHERE
        subject_id = ?
    SQL
    return nil if data.length == 0

    data.map { |datum| Reply.new(datum) }
  end


  def initialize(options)
    @id = options['id']
    @body = options['body']
    @subject_id = options['subject_id']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
  end

  def create
    raise "#{self} already exists!" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @body, @subject_id, @parent_id, @user_id)
      INSERT INTO
        replies (body, subject_id, parent_id, user_id)
      VALUES
        (?, ?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} doesn't exist!" if !@id
    QuestionsDatabase.instance.execute(<<-SQL, @body, @subject_id, @parent_id, @user_id, @id)
      UPDATE
        replies
      SET
        body = ?, subject_id = ?, parent_id = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end
end


class QuestionFollow #medium
  attr_accessor :question_id, :user_id
  attr_reader :id

  def self.find_by_id(id)

  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

end


class QuestionLike


end
