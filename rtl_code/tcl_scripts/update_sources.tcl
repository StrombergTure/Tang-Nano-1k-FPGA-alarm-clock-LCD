# -------------------------------------------------------------
# Update Vivado source files from your RTL, SRC, and TB directories
# -------------------------------------------------------------

set rtl_path {C:/Users/Maximus/Documents/ALARM_CLOCK/Tang-Nano-1k-FPGA-alarm-clock-LCD/rtl_code/}
set src_path {C:/Users/Maximus/Documents/ALARM_CLOCK/fpga_projects/alarm_clock/src}
set tb_path  {C:/Users/Maximus/Documents/ALARM_CLOCK/Tang-Nano-1k-FPGA-alarm-clock-LCD/rtl_code/tb}

# -------------------------------------------------------------
# Remove existing files safely
# -------------------------------------------------------------

set srcFiles   [get_files -filter {FILE_TYPE == "Verilog" || FILE_TYPE == "SystemVerilog"} -of_objects [get_filesets sources_1]]
if {[llength $srcFiles] > 0} {
    remove_files -fileset sources_1 $srcFiles
}

set simFiles   [get_files -filter {FILE_TYPE == "Verilog" || FILE_TYPE == "SystemVerilog"} -of_objects [get_filesets sim_1]]
if {[llength $simFiles] > 0} {
    remove_files -fileset sim_1 $simFiles
}

# -------------------------------------------------------------
# Create sources_1 fileset if needed
# -------------------------------------------------------------

if {[catch {get_fileset sources_1}]} {
    create_fileset -srcset sources_1
} else {
    puts "Fileset sources_1 already exists"
}

# Add your RTL/SRC files
# add_files -norecurse -fileset sources_1 [glob -nocomplain ${rtl_path}/*.sv]
add_files -norecurse -fileset sources_1 [glob -nocomplain ${src_path}/*.sv]

update_compile_order -fileset sources_1

# -------------------------------------------------------------
# Create sim_1 fileset if needed
# -------------------------------------------------------------

if {[catch {get_fileset sim_1}]} {
    create_fileset -simset sim_1
} else {
    puts "Fileset sim_1 already exists"
}

# Add your TB files
add_files -norecurse -fileset sim_1 [glob -nocomplain ${tb_path}/*.sv]

update_compile_order -fileset sim_1

# -------------------------------------------------------------
# Output status
# -------------------------------------------------------------
puts "✅ Sources updated"
report_compile_order -fileset sources_1

puts "✅ Testbench updated"
report_compile_order -fileset sim_1
