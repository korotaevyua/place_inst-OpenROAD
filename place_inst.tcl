proc place_inst {inst_name x_microns y_microns} {
    # Get the current dbBlock
    set block [ord::get_db_block]
    if { $block == "" } {
        puts "Error: No dbBlock found. Did you read a DEF or DB?"
        return
    }

    # Find the instance
    set inst [$block findInst $inst_name]
    if { $inst == "" } {
        puts "Error: Instance '$inst_name' not found."
        return
    }

    # Convert microns to DBU by multiplying by 1000
    set x_dbu [expr {$x_microns * 1000}]
    set y_dbu [expr {$y_microns * 1000}]

    # Set the location in DBUs
    $inst setLocation $x_dbu $y_dbu

    # Mark the instance as placed (retains the existing orientation)
    $inst setPlacementStatus PLACED

    puts "Instance '$inst_name' placed at ($x_microns, $y_microns) microns -> ($x_dbu, $y_dbu) DBU."
}

