#
# check_if_globally_placed
#   Returns 1 if all standard cells are placed or fixed, 0 otherwise.
#   Prints warnings/errors as needed.
#
proc check_if_globally_placed {} {
    # Get the top-level dbBlock
    set block [ord::get_db_block]
    if { $block == "" } {
        puts "ERROR: No dbBlock found. Did you read a design (LEF/DEF)?"
        return 0
    }

    set std_cells_count 0
    set placed_count 0

    # Iterate over all instances
    foreach inst [$block getInsts] {
        set master [$inst getMaster]

        # isCore == 1 indicates a standard-cell master
        if { [$master isCore] == 1 } {
            incr std_cells_count
            set status [$inst getPlacementStatus]
            # We consider 'PLACED' or 'FIXED' as being physically placed
            if { $status eq "PLACED" || $status eq "FIXED" } {
                incr placed_count
            }
        }
    }

    if { $std_cells_count == 0 } {
        puts "WARNING: No standard cells found in the design."
        return 0
    } elseif { $placed_count == $std_cells_count } {
        # All standard cells are placed/fixed
        return 1
    } else {
        # Some standard cells remain UNPLACED (or other statuses)
        return 0
    }
}

#
# place_inst
#   Places a specified instance at (x_microns, y_microns).
#   But first checks if the design is globally placed.
#   If not, it refuses to proceed.
#   Finally, it calls 'detailed_placement' for incremental placement
#
proc place_inst {inst_name x_microns y_microns} {

    # 1) Check if design is globally placed
    if {[check_if_globally_placed] == 0} {
        puts "ERROR: The design must be globally placed before calling place_inst."
        return
    }

    # 2) Get the dbBlock and find the instance
    set block [ord::get_db_block]
    if { $block == "" } {
        puts "ERROR: No dbBlock found. Did you read a design?"
        return
    }

    set inst [$block findInst $inst_name]
    if { $inst == "" } {
        puts "ERROR: Instance '$inst_name' not found."
        return
    }

    # 3) Convert microns -> DBU
    #    (Assuming 1 micron = 1000 DBUs; adjust if your tech uses a different scale.)
    set x_dbu [expr {$x_microns * 1000}]
    set y_dbu [expr {$y_microns * 1000}]

    # 4) Place the instance at the given location
    $inst setLocation $x_dbu $y_dbu
    $inst setPlacementStatus PLACED

    puts "INFO: Placed instance '$inst_name' at ($x_microns, $y_microns) microns, i.e. ($x_dbu, $y_dbu) DBU."

    # 5) Call  “detailed_placement” command
    detailed_placement
}
