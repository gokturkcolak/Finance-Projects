import os
import yfinance as yf
from tkinter import Tk, Label, Entry, Button, filedialog, messagebox, StringVar, OptionMenu

def download_data():
    # Get user inputs
    tickers = ticker_entry.get()
    start_date = start_date_entry.get()
    end_date = end_date_entry.get()
    frequency = frequency_var.get()
    download_dir = directory_label.cget("text")
    
    # Validate inputs
    if not tickers or not start_date or not end_date or not download_dir or not frequency:
        messagebox.showerror("Error", "Please fill in all fields and select a directory.")
        return
    
    tickers_list = tickers.split(",")
    for ticker in tickers_list:
        ticker = ticker.strip()
        try:
            # Download data
            print(f"Downloading data for {ticker} with frequency '{frequency}'...")
            data = yf.download(ticker, start=start_date, end=end_date, interval=frequency)
            if not data.empty:
                file_path = os.path.join(download_dir, f"{ticker}_data.csv")
                data.to_csv(file_path)
                print(f"Data for {ticker} saved to {file_path}")
            else:
                print(f"No data found for {ticker}.")
        except Exception as e:
            print(f"Failed to download data for {ticker}: {e}")
    
    messagebox.showinfo("Success", "Data download completed!")

def select_directory():
    # Open a directory selection dialog
    folder_selected = filedialog.askdirectory(title="Select Download Directory")
    if folder_selected:
        directory_label.config(text=folder_selected)

# Create the main application window
root = Tk()
root.title("Yahoo Finance Data Downloader")

# Create and place widgets
Label(root, text="Tickers (comma-separated):").grid(row=0, column=0, padx=10, pady=5, sticky="e")
ticker_entry = Entry(root, width=30)
ticker_entry.grid(row=0, column=1, padx=10, pady=5)

Label(root, text="Start Date (YYYY-MM-DD):").grid(row=1, column=0, padx=10, pady=5, sticky="e")
start_date_entry = Entry(root, width=30)
start_date_entry.grid(row=1, column=1, padx=10, pady=5)

Label(root, text="End Date (YYYY-MM-DD):").grid(row=2, column=0, padx=10, pady=5, sticky="e")
end_date_entry = Entry(root, width=30)
end_date_entry.grid(row=2, column=1, padx=10, pady=5)

Label(root, text="Frequency:").grid(row=3, column=0, padx=10, pady=5, sticky="e")
frequency_var = StringVar(root)
frequency_var.set("1d")  # Default frequency is daily
frequency_menu = OptionMenu(root, frequency_var, "1d", "1wk", "1mo")
frequency_menu.grid(row=3, column=1, padx=10, pady=5, sticky="w")

Label(root, text="Download Directory:").grid(row=4, column=0, padx=10, pady=5, sticky="e")
directory_label = Label(root, text="", width=30, anchor="w", bg="white", relief="sunken")
directory_label.grid(row=4, column=1, padx=10, pady=5)

select_dir_button = Button(root, text="Browse", command=select_directory)
select_dir_button.grid(row=4, column=2, padx=10, pady=5)

download_button = Button(root, text="Download Data", command=download_data)
download_button.grid(row=5, column=1, pady=20)

# Start the GUI event loop
root.mainloop()

