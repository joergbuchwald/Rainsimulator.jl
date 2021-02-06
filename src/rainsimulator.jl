### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 9661e304-39b3-11eb-1373-c3959d5b37ff
using Plots

# ╔═╡ 838d642e-399f-11eb-36f4-6fd348a4f84d
begin
	import DarkMode
	DarkMode.enable()
end

# ╔═╡ 4a5a6590-399e-11eb-0931-c737ec2e34e4
struct rainsimulator
	l::Float64 # path length
	h::Float64 # modelregion height
	vr::Float64 # rain velocity
 	vm::Float64 # agent velocity
	θ::Float64 # angle with respect to vertical
	ρR::Float64 # rain density
	a::Float64 # head diameter
	b::Float64 # agent height
	Δt::Float64 #timestep
end

# ╔═╡ 206e2cca-399f-11eb-2ee0-d9f9456ebbdb
mutable struct rain
	x_pos::Array
	y_pos::Array
end

# ╔═╡ 3e015876-39a3-11eb-21a1-d90460d77835
mutable struct agent
	x_pos::Float64
	y_pos::Float64
end

# ╔═╡ 2f4c2286-39ab-11eb-1c23-e998a265526a
mutable struct response
	time::Array
	cummulative_hits::Array
end

# ╔═╡ dcc75c1e-39ad-11eb-0b0b-13add6a0ec03


# ╔═╡ 6c5ea9ba-39a2-11eb-0fa2-71931a4498ee


# ╔═╡ ae4cc5ea-39a1-11eb-2079-69a20a3b9a45
function init_field(config::rainsimulator)
	density = config.ρR
	dim_x = config.l
	dim_y = config.h
	numofraindrops = convert(Int64,floor(dim_x*dim_y*density))
	rain(dim_x*rand(numofraindrops),dim_y*rand(numofraindrops))
end

# ╔═╡ 442d4544-39a7-11eb-385c-035da6732479
function update_rain!(raininstanz::rain,config::rainsimulator)
	θ = config.θ
	vr = config.vr
	Δt = config.Δt
	Δx = -cosd(θ)
	Δy = -sind(θ)
	raininstanz.x_pos = raininstanz.x_pos .+ (Δx * vr* Δt)
	raininstanz.y_pos = raininstanz.y_pos .+ (Δy * vr* Δt)
	for i in 1:length(raininstanz.x_pos)
		if raininstanz.x_pos[i] < 0
			raininstanz.x_pos[i] += config.l
		end
		if raininstanz.x_pos[i] > config.l
			raininstanz.x_pos[i] -= config.l
		end
		if raininstanz.y_pos[i] < 0
			raininstanz.y_pos[i] += config.h	
		end
		if raininstanz.y_pos[i] > config.h
			raininstanz.y_pos[i] -= config.h
		end
	end
end

# ╔═╡ d7a666de-39a7-11eb-0537-ebd5786d023a
function update_agent!(agentinstanz::agent,config::rainsimulator)
	vm = config.vm
	Δt = config.Δt
	agentinstanz.x_pos += vm * Δt
end

# ╔═╡ 6f2bde14-39ab-11eb-2197-d1af40ec3dd8
function check_hit_drops!(
		responseinstanz::response,
		raininstanz::rain,
		agentinstanz::agent,
		config::rainsimulator)
	x_a = agentinstanz.x_pos
	y_a = 0.0
	x_b = agentinstanz.x_pos + config.a
	y_b = config.b
	y = raininstanz.y_pos
	push!(responseinstanz.cummulative_hits,0)
	for i in 1:length(raininstanz.x_pos)
		if (raininstanz.x_pos[i] > x_a) && (raininstanz.x_pos[i] < x_b)
			if (raininstanz.y_pos[i] > y_a) && (raininstanz.y_pos[i] < y_b)
				responseinstanz.cummulative_hits[end] += 1
				raininstanz.x_pos[i] = config.l*rand()
				raininstanz.y_pos[i] = config.h*rand()
			end
		end
	end
end

# ╔═╡ 68a7ee40-39ac-11eb-3b89-b9a85874f469
function maketimestep!(responseinstanz::response,
		raininstanz::rain,
		agentinstanz::agent,
		config::rainsimulator)
	update_rain!(raininstanz, config)
	update_agent!(agentinstanz, config)
	check_hit_drops!(responseinstanz,raininstanz,agentinstanz,config)
	push!(responseinstanz.time,responseinstanz.time[end] + config.Δt)
end
	

# ╔═╡ 266f8b74-39af-11eb-28fb-d7deda1a1a36
function run(config::rainsimulator)
	responseinstanz = response([0.0],[0])
	agentinstanz = agent(0,0)
	rainfield = init_field(config)
	n = ceil(config.l/(config.vm*config.Δt))
	print(n)
	for i in 1:n
		maketimestep!(responseinstanz,rainfield,agentinstanz, config)
	end
	responseinstanz
end	

# ╔═╡ f5c27d76-39af-11eb-3e30-d37e2db01542
begin
	c1=rainsimulator(100, 100, 5.1, 1, 89, 1, 0.5, 2, 0.01)
	c2=rainsimulator(100, 100, 5.1, 5.1, 89, 1, 0.5, 2, 0.01)
	c3=rainsimulator(100, 100, 5.1, 10, 89, 1, 0.5, 2, 0.01)
	c4=rainsimulator(100, 100, 5.1, 1, -89, 1, 0.5, 2, 0.01)
	c5=rainsimulator(100, 100, 5.1, 5.1, -89, 1, 0.5, 2, 0.01)
	c6=rainsimulator(100, 100, 5.1, 10, -89, 1, 0.5, 2, 0.01)
end

# ╔═╡ 7cb9b56a-39b0-11eb-31a0-b98dcd35ad08
begin
	output1=run(c1)
	output2=run(c2)
	output3=run(c3)
	output4=run(c4)
	output5=run(c5)
	output6=run(c6)
end

# ╔═╡ 86fef7d2-68a0-11eb-1974-4d2695221bdf
output1.cummulative_hits

# ╔═╡ b41fdc84-39b3-11eb-0107-2fff3564a831


# ╔═╡ e814282e-39b3-11eb-0698-5b00781a15c0
begin 
	pl = plot()
	plot!(output1.time,output1.cummulative_hits)
	plot!(output2.time,output2.cummulative_hits)
	plot!(output3.time,output3.cummulative_hits)
	pl
end

# ╔═╡ b9893c4a-39b5-11eb-042a-99e76c8f37f9
begin
	pl2 = plot()
	plot!(output1.time,cumsum(output1.cummulative_hits))
	plot!(output2.time,cumsum(output2.cummulative_hits))
	plot!(output3.time,cumsum(output3.cummulative_hits))
	plot!(output4.time,cumsum(output4.cummulative_hits))
	plot!(output5.time,cumsum(output5.cummulative_hits))
	plot!(output6.time,cumsum(output6.cummulative_hits))
	pl2
end

# ╔═╡ Cell order:
# ╠═838d642e-399f-11eb-36f4-6fd348a4f84d
# ╠═4a5a6590-399e-11eb-0931-c737ec2e34e4
# ╠═206e2cca-399f-11eb-2ee0-d9f9456ebbdb
# ╠═3e015876-39a3-11eb-21a1-d90460d77835
# ╠═2f4c2286-39ab-11eb-1c23-e998a265526a
# ╠═dcc75c1e-39ad-11eb-0b0b-13add6a0ec03
# ╠═6c5ea9ba-39a2-11eb-0fa2-71931a4498ee
# ╠═ae4cc5ea-39a1-11eb-2079-69a20a3b9a45
# ╠═442d4544-39a7-11eb-385c-035da6732479
# ╠═d7a666de-39a7-11eb-0537-ebd5786d023a
# ╠═6f2bde14-39ab-11eb-2197-d1af40ec3dd8
# ╠═68a7ee40-39ac-11eb-3b89-b9a85874f469
# ╠═266f8b74-39af-11eb-28fb-d7deda1a1a36
# ╠═f5c27d76-39af-11eb-3e30-d37e2db01542
# ╠═7cb9b56a-39b0-11eb-31a0-b98dcd35ad08
# ╠═86fef7d2-68a0-11eb-1974-4d2695221bdf
# ╠═9661e304-39b3-11eb-1373-c3959d5b37ff
# ╠═b41fdc84-39b3-11eb-0107-2fff3564a831
# ╠═e814282e-39b3-11eb-0698-5b00781a15c0
# ╠═b9893c4a-39b5-11eb-042a-99e76c8f37f9
