#!/usr/bin/env elixir

defmodule DateConverter do
  @month_map %{
    "January" => "01",
    "February" => "02",
    "March" => "03",
    "April" => "04",
    "May" => "05",
    "June" => "06",
    "July" => "07",
    "August" => "08",
    "September" => "09",
    "October" => "10",
    "November" => "11",
    "December" => "12"
  }

  def convert_date(date_string) do
    case String.split(date_string, " ") do
      [month, day_and_comma, year] ->
        day = String.trim_trailing(day_and_comma, ",")
        month_number = Map.get(@month_map, month)

        if month_number do
          {:ok, "#{year}-#{month_number}-#{String.pad_leading(day, 2, "0")}"}
        else
          {:error, "Invalid month name: #{month}"}
        end

      _ ->
        {:error, "Invalid date format. Expected format: 'Month Day, Year' (e.g., 'October 20, 1999')."}
    end
  end
end

defmodule CLI do
  def main(args) do
    case args do
      [date_string] ->
        case DateConverter.convert_date(date_string) do
          {:ok, converted_date} ->
            IO.puts(converted_date)

          {:error, message} ->
            IO.puts(:stderr, "Error: #{message}")
        end

      _ ->
        IO.puts(:stderr, "Usage: elixir convert_date.exs \"Month Day, Year\"")
    end
  end
end

# Entrypoint
CLI.main(System.argv())
