defmodule OpenBudgetWeb.AccountControllerTest do
  use OpenBudgetWeb.ConnCase

  alias OpenBudget.Budgets
  alias OpenBudget.Budgets.Account

  @create_attrs %{description: "some description", name: "some name", type: "some type"}
  @update_attrs %{description: "some updated description", name: "some updated name", type: "some updated type"}
  @invalid_attrs %{description: nil, name: nil, type: nil}

  def fixture(:account) do
    {:ok, account} = Budgets.create_account(@create_attrs)
    account
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all accounts", %{conn: conn} do
      conn = get conn, account_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create account" do
    test "renders account when data is valid", %{conn: conn} do
      conn = post conn, account_path(conn, :create), account: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, account_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "description" => "some description",
        "name" => "some name",
        "type" => "some type"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, account_path(conn, :create), account: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update account" do
    setup [:create_account]

    test "renders account when data is valid", %{conn: conn, account: %Account{id: id} = account} do
      conn = put conn, account_path(conn, :update, account), account: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, account_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "description" => "some updated description",
        "name" => "some updated name",
        "type" => "some updated type"}
    end

    test "renders errors when data is invalid", %{conn: conn, account: account} do
      conn = put conn, account_path(conn, :update, account), account: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete account" do
    setup [:create_account]

    test "deletes chosen account", %{conn: conn, account: account} do
      conn = delete conn, account_path(conn, :delete, account)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, account_path(conn, :show, account)
      end
    end
  end

  defp create_account(_) do
    account = fixture(:account)
    {:ok, account: account}
  end
end