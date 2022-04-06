import Agents
import InteractiveDynamics
import GLMakie

# Required to have "id" and "pos" attributes
mutable struct Cell <: Agents.AbstractAgent
    id::Int
    pos::Tuple{Int, Int}
    status::Bool
end

function create_model()
    # Create the grid world and environment
    grid_size = (50, 50)
    grid = Agents.GridSpace(grid_size)
    model = Agents.ABM(Cell, grid)
    
    # Fill every grid with a Cell
    cell_id = 1
    for x in 1:grid_size[1], y in 1:grid_size[2]
        cell = Cell(cell_id, (x, y), false)
        Agents.add_agent_pos!(cell, model)
        cell_id += 1
    end

    return model
end

function step!(model)
    list = String[]
    for k in 1:length(keys(model.agents))
        # Bottom left corner check
        if k == 1
            bottomLeft(k, model, list)

        # Top left corner check
        elseif k == 50
            topLeft(k, model, list)
            
        # Top right corner check
        elseif k == 2500
            topRight(k, model, list)

        # Bottom right corner check
        elseif k == 2451
            bottomRight(k, model, list)
        
        # Left wall check
        elseif k <= 50
            leftWall(k, model, list)

        # Top wall check
        elseif k % 50 == 0
            topWall(k, model, list)

        # Right wall check
        elseif k >= 2451
            rightWall(k, model, list)

        # Bottom wall check
        elseif k % 50 == 1
            bottomWall(k, model, list)

        # If none of the above, it must be a middle cell
        else
            middle(k, model, list)
        end
    end

    for i in 1:length(list)
        if list[i] == "True"
            model.agents[i].status = true
        end
        if list[i] == "False"
            model.agents[i].status = false
        end
    end
end

# Functions to edit cells depending on location
function bottomLeft(cell, model, list)
    counter = 0

    # Check how many alive neighbors there are
    if model.agents[cell + 1].status
        counter += 1
    end
    if model.agents[cell + 51].status
        counter += 1
    end
    if model.agents[cell + 50].status
        counter += 1
    end

    # Call the function to see if the cell should be alive or dead
    changeCell(counter, list, cell, model)
end

function topLeft(cell, model, list)
    counter = 0

    # Check how many alive neighbors there are
    if model.agents[cell + 50].status
        counter += 1
    end
    if model.agents[cell + 49].status
        counter += 1
    end
    if model.agents[cell - 1].status
        counter += 1
    end

    # Call the function to see if the cell should be alive or dead
    changeCell(counter, list, cell, model)
end

function topRight(cell, model, list)
    counter = 0

    # Check how many alive neighbors there are
    if model.agents[cell - 50].status
        counter += 1
    end
    if model.agents[cell - 51].status
        counter += 1
    end
    if model.agents[cell - 1].status
        counter += 1
    end

    # Call the function to see if the cell should be alive or dead
    changeCell(counter, list, cell, model)
end

function bottomRight(cell, model, list)
    counter = 0

    # Check how many alive neighbors there are
    if model.agents[cell - 50].status
        counter += 1
    end
    if model.agents[cell - 49].status
        counter += 1
    end
    if model.agents[cell + 1].status
        counter += 1
    end

    # Call the function to see if the cell should be alive or dead
    changeCell(counter, list, cell, model)
end

function leftWall(cell, model, list)
    counter = 0

    # Check how many alive neighbors there are
    if model.agents[cell - 1].status
        counter += 1
    end
    if model.agents[cell + 49].status
        counter += 1
    end
    if model.agents[cell + 50].status
        counter += 1
    end
    if model.agents[cell + 51].status
        counter += 1
    end
    if model.agents[cell + 1].status
        counter += 1
    end

    # Call the function to see if the cell should be alive or dead
    changeCell(counter, list, cell, model)
end

function topWall(cell, model, list)
    counter = 0

    # Check how many alive neighbors there are
    if model.agents[cell - 50].status
        counter += 1
    end
    if model.agents[cell - 51].status
        counter += 1
    end
    if model.agents[cell - 1].status
        counter += 1
    end
    if model.agents[cell + 49].status
        counter += 1
    end
    if model.agents[cell + 50].status
        counter += 1
    end

    # Call the function to see if the cell should be alive or dead
    changeCell(counter, list, cell, model)
end

function bottomWall(cell, model, list)
    counter = 0

    # Check how many alive neighbors there are
    if model.agents[cell - 50].status
        counter += 1
    end
    if model.agents[cell - 49].status
        counter += 1
    end
    if model.agents[cell + 1].status
        counter += 1
    end
    if model.agents[cell + 51].status
        counter += 1
    end
    if model.agents[cell + 50].status
        counter += 1
    end

    # Call the function to see if the cell should be alive or dead
    changeCell(counter, list, cell, model)
end

function rightWall(cell, model, list)
    counter = 0

    # Check how many alive neighbors there are
    if model.agents[cell - 1].status
        counter += 1
    end
    if model.agents[cell - 51].status
        counter += 1
    end
    if model.agents[cell - 50].status
        counter += 1
    end
    if model.agents[cell - 49].status
        counter += 1
    end
    if model.agents[cell + 1].status
        counter += 1
    end

    # Call the function to see if the cell should be alive or dead
    changeCell(counter, list, cell, model)
end

function middle(cell, model, list)
    counter = 0

    # Check how many alive neighbors there are
    if model.agents[cell - 49].status
        counter += 1
    end
    if model.agents[cell + 1].status
        counter += 1
    end
    if model.agents[cell + 51].status
        counter += 1
    end
    if model.agents[cell + 50].status
        counter += 1
    end
    if model.agents[cell + 49].status
        counter += 1
    end
    if model.agents[cell - 1].status
        counter += 1
    end
    if model.agents[cell - 51].status
        counter += 1
    end
    if model.agents[cell - 50].status
        counter += 1
    end

    # Call the function to see if the cell should be alive or dead
    changeCell(counter, list, cell, model)
end

# Function to switch the state of the current cell
function changeCell(counter, list, cell, model)

    # If current cell is alive, only 2 or 3 live neighbors can keep it alive
    if model.agents[cell].status == true
        if counter == 2 || counter == 3
            push!(list, "True")
        else
            push!(list, "False")
        end
    
    # If current cell is dead, only 3 live neighbors can turn it to alive
    else
        if counter == 3
            push!(list, "True")
        else
            push!(list, "False")
        end
    end
end

# Sets the inital state of the model
function initialize_cells(model)

    # Array that contains starter cells
    # Block is on line 314
    # Beehive is on line 315
    # Blinker is on line 316
    # Penta Decathlon is on line 317
    # Glider is on line 318
    # Spaceship is on line 319

    start = [225, 226, 275, 276, 
    410, 459, 461, 509, 511, 560, 
    1040, 1041, 1042,
    1025, 1075, 1124, 1126, 1175, 1225, 1275, 1325, 1374, 1376, 1425, 1475,
    1248, 1297, 1347, 1348, 1349,
    518, 516, 565, 615, 665, 715, 716, 717, 668]

    for x in 1:length(model.agents)
        turn_on = false
        if x in start
            turn_on = true
        end
        model.agents[x].status = turn_on
    end
end


################################################################################
# Main
################################################################################

model = create_model()
initialize_cells(model)

# Animate the model
alive(x::Cell) = x.status == true
dead(x::Cell) = x.status == false
color(x::Cell) = x.status ? "black" : "white"
as = 8
am = '●'
adata = [(alive, count), (dead, count)]
scatterkwargs = (strokewidth = 1.0,)

fig, p = InteractiveDynamics.abmexploration(
    model;
    model_step! = step!,
    ac = color,
    as,
    am,
    scatterkwargs,
    adata,
    alabels=["Alive", "Dead"],
)
fig
