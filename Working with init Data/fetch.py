import csv
import json
from pathlib import Path


root= Path(__file__).resolve().parent.parent
int_field = ("age","fee_inr","prior_no_shows")
float_field = ("distance_km",)



def parse_row(row: dict) -> dict:
    parsed = dict(row)

    for i in int_field:
        try:
            parsed[i] = int(row[i])
        except ValueError:
            raise ValueError(f"Invalid integer value for field '{i}': {row[i]}")
    for i in float_field:
        try:
            parsed[i] = float(row[i])
        except ValueError:
            raise ValueError(f"Invalid float value for field '{i}': {row[i]}")
    return parsed




def read_appointments(path: Path) -> tuple[list[dict], list[dict]]:
    accepted_rows, rejected_rows = [], []

    with open(path, newline = "") as f:
        rows = csv.DictReader(f)
        print(f"Header:  {rows.fieldnames}")

        for i in rows:
            try:
                accepted_rows.append(parse_row(i))
            except ValueError as v:
                rejected_rows.append(i)
                print(f"Error parsing row: {v}")

    print(f"Rows read: {len(accepted_rows) + len(rejected_rows)}")
    print(f"Accepted: {len(accepted_rows)}, Rejected: {len(rejected_rows)}")
    return accepted_rows, rejected_rows


def save_rejected_rows(rejected_rows: list[dict], path: Path) -> None:
    if not rejected_rows:
        print("No rejected rows to save.")
        return

    with open(path, "w") as f:
        json.dump(rejected_rows, f, indent=2)


if __name__ == "__main__":
    input_path = root / "data" / "appointments.csv"
    rejected_path = root / "data" / "rejected_rows.json"

    accepted, rejected = read_appointments(input_path)
    save_rejected_rows(rejected, rejected_path)