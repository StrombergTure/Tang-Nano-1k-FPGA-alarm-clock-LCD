# -------------------------------------------------------------
# Update Vivado source files from your RTL, SRC, and TB directories
# -------------------------------------------------------------

# Define your paths
set rtl_path {C:/Users/Maximus/Documents/Tang-Nano-1k-FPGA-alarm-clock-LCD/rtl_code/rtl}
set src_path {C:/Users/Maximus/Documents/Tang-Nano-1k-FPGA-alarm-clock-LCD/rtl_code/src}
set tb_path  {C:/Users/Maximus/Documents/Tang-Nano-1k-FPGA-alarm-clock-LCD/rtl_code/tb}

# Optional: remove existing files from filesets to avoid duplicates
# Remove from sources fileset
remove_files -fileset sources_1 [get_files -filter {FILE_TYPE == "Verilog" || FILE_TYPE == "SystemVerilog"}]
# Remove from simulation fileset
remove_files -fileset sim_1 [get_files -filter {FILE_TYPE == "Verilog" || FILE_TYPE == "SystemVerilog"}]

# -------------------------------------------------------------
# Add RTL/SRC files to sources fileset
# -------------------------------------------------------------
# Create sources_1 fileset if it doesn't exist
if {![catch {get_fileset sources_1}]} {
    puts "Fileset sources_1 already exists"
} else {
    create_fileset -fileset sources_1 -type "Sources"
}

# Add all .v and .sv files from rtl and src
# add_files -norecurse -fileset sources_1 [glob -nocomplain ${rtl_path}/*.sv]
# add_files -norecurse -fileset sources_1 [glob -nocomplain ${rtl_path}/*.v]
add_files -norecurse -fileset sources_1 [glob -nocomplain ${src_path}/*.sv]
# add_files -norecurse -fileset sources_1 [glob -nocomplain ${src_path}/*.v]

# Update compile order for sources
update_compile_order -fileset sources_1

# -------------------------------------------------------------
# Add testbench files to simulation fileset
# -------------------------------------------------------------
# Create sim_1 fileset if it doesn't exist
if {![catch {get_fileset sim_1}]} {
    puts "Fileset sim_1 already exists"
} else {
    create_fileset -fileset sim_1 -type "Simulation Sources"
}

# Add all .v and .sv files from tb folder
add_files -norecurse -fileset sim_1 [glob -nocomplain ${tb_path}/*.sv]
# add_files -norecurse -fileset sim_1 [glob -nocomplain ${tb_path}/*.v]

# Update compile order for simulation
update_compile_order -fileset sim_1

# -------------------------------------------------------------
# Optional: display results
# -------------------------------------------------------------
puts "✅ Sources updated from: $rtl_path and $src_path"
report_compile_order -fileset sources_1

puts "✅ Testbench files updated from: $tb_path"
report_compile_order -fileset sim_1
