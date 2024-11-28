using Ipaper

# merge_pdf()
files = ["./傅里叶变化.pdf", "./notebooks/傅里叶变化 - JupyterLab.pdf"]
fout = "3.1 傅里叶变化.pdf"
run(`pdftk $files cat output $fout`)
