# encoding: UTF-8
require "test/unit"
require File.expand_path('../bank_account',  __FILE__)

class AccountsTest < Test::Unit::TestCase

  def test_initial_limit
    assert_equal 0, Bank::Account.open.limit
    assert_equal 10_000, Bank::GoldenAccount.open.limit
    assert_equal 100_000, Bank::DiamondAccount.open.limit
  end

  def test_initial_balance
    assert_equal 0, Bank::Account.open.balance
    assert_equal 0, Bank::GoldenAccount.open.balance
    assert_equal 0, Bank::DiamondAccount.open.balance
  end

  def test_initial_balance_passing_ammount
    assert_equal 1000, Bank::Account.open(1000).balance
    assert_equal 1000, Bank::GoldenAccount.open(1000).balance
    assert_equal 1000, Bank::DiamondAccount.open(1000).balance
  end

  def test_deposit
    account = Bank::Account.open
    account.deposit(100)
    assert_equal 100, account.balance
  end

  def test_plus
    account = Bank::Account.open
    account + 100
    assert_equal 100, account.balance
  end

  def test_draw
    account = Bank::Account.open(1000)
    account.draw(100)
    assert_equal 900, account.balance
  end

  def test_minus
    account = Bank::Account.open(1000)
    account - 100
    assert_equal 900, account.balance
  end

  def test_validate_limit_on_account
    account = Bank::Account.open
    assert ! account.draw(100)
    assert_equal 0, account.balance
  end

  def test_validate_limit_on_golden_account
    account = Bank::GoldenAccount.open
    assert account.draw(9_000)
    assert_equal -9_000, account.balance
    assert ! account.draw(2_000)
    assert_equal -9_000, account.balance
  end

  def test_validate_limit_on_diamond_account
    account = Bank::DiamondAccount.open
    assert account.draw(99_000)
    assert_equal -99_000, account.balance
    assert ! account.draw(2_000)
    assert_equal -99_000, account.balance
  end

  def test_transfer
    john = Bank::DiamondAccount.open
    mary = Bank::DiamondAccount.open
    assert john.transfer(mary, 100)
    assert_equal -100, john.balance
    assert_equal 100, mary.balance
  end

  def test_transfer_should_validate_limits
    john = Bank::Account.open
    mary = Bank::DiamondAccount.open
    assert ! john.transfer(mary, 100)
    assert_equal 0, john.balance
    assert_equal 0, mary.balance
  end

  def test_initial_operation
    operation = Bank::Account.open.operations.first
    assert_equal :create, operation[0]
    assert operation[1].is_a? Time
  end

  def test_operation_initializing_with_deposit
    account = Bank::Account.open(1_000)
    operation = account.operations.last
    assert_equal :deposit, operation[0]
    assert operation[1].is_a? Time
    assert_equal 1_000, operation[2]
  end

  def test_operation_depositing
    account = Bank::Account.open
    account.deposit(1_000)
    operation = account.operations.last
    assert_equal :deposit, operation[0]
    assert operation[1].is_a? Time
    assert_equal 1_000, operation[2]
  end

  def test_operation_with_plus
    account = Bank::Account.open
    account + 1_000
    operation = account.operations.last
    assert_equal :deposit, operation[0]
    assert operation[1].is_a? Time
    assert_equal 1_000, operation[2]
  end

  def test_operation_drawing
    account = Bank::DiamondAccount.open
    account.draw(2_000)
    operation = account.operations.last
    assert_equal :draw, operation[0]
    assert operation[1].is_a? Time
    assert_equal 2_000, operation[2]
  end

  def test_operation_with_minus
    account = Bank::DiamondAccount.open
    account - 2_000
    operation = account.operations.last
    assert_equal :draw, operation[0]
    assert operation[1].is_a? Time
    assert_equal 2_000, operation[2]
  end

  def test_to_i
    account = Bank::DiamondAccount.open(1_000)
    assert_equal 1_000, account.to_i
  end

  def test_sort
    john = Bank::DiamondAccount.open(3_000)
    mary = Bank::GoldenAccount.open(2_000)
    jim = Bank::Account.open(1_000)
    assert_equal [jim, mary, john], [john, mary, jim].sort
  end

  def test_accounts_method
    a = Bank::DiamondAccount.open
    b = Bank::GoldenAccount.open
    c = Bank::Account.open
    assert_equal [a, b, c], Bank::Account.accounts
  end

end