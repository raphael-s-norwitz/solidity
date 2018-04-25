/*
	This file is part of solidity.

	solidity is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	solidity is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with solidity.  If not, see <http://www.gnu.org/licenses/>.
*/
/**
 * @author Killian <krr2125@columbia.edu>
 * @author Jiayang <prokingsley@gmail.com>
 * @author Raphael <raphael.s.norwitz@gmail.com>
 * @date 2017
 * A timing utility for debugging compiler performance
 */
#include <stdexcept>
#include <iostream>
#include <sstream>
#include <iomanip>
#include <chrono>
#include <ctime>

#include "FTime.h"

using namespace std;

TimeNodeWrapper::TimeNodeWrapper(TimeNodeStack& t_stack, string name): stack(t_stack) {
	t_stack.push(name);
	popped = false;
}

TimeNodeWrapper::~TimeNodeWrapper() {
	if (!popped) {
		stack.pop();
		popped = true;
	}
}

void TimeNodeWrapper::pop() {
	if (!popped) {
		stack.pop();
		popped = true;
	} else {
		cout << "Error: Already popped!\n";
	}
}

TimeNode::TimeNode() {
	children = vector<TimeNode>();
}

void TimeNode::setBegin() {
	begin = std::chrono::high_resolution_clock::now();
}

void TimeNode::setEnd() {
	end = std::chrono::high_resolution_clock::now();
}

const std::chrono::high_resolution_clock::time_point TimeNode::getBegin() const {
	return begin;
}

const std::chrono::high_resolution_clock::time_point TimeNode::getEnd() const {
	return end;
}

TimeNodeStack::TimeNodeStack()
{
	start = std::chrono::high_resolution_clock::now();
}

TimeNodeStack::~TimeNodeStack()
{
        //TODO: only print to cerr for the moment as we were advised
        //not to throw error in destructor
        if (print_flag && stack.size() != 0)
        {
                cerr << "Warning: there are still " << stack.size() << 
                        " elements in the stack: call respective pop function for: " << '\n';
                for (TimeNode node : stack)
                {
                        cerr << node.name << '\n';
                }
        }
}
                
void TimeNodeStack::push(string name)
{
	TimeNode t_node;
	t_node.name = name;
	t_node.setBegin();
	stack.push_back(t_node);
}

void TimeNodeStack::pop()
{
	if (stack.size() > 1)
	{
		TimeNode t_node = stack[stack.size() - 1];
		stack.pop_back();
		t_node.setEnd();
		stack[stack.size() - 1].children.push_back(t_node);
	}
	else if (stack.size() == 1)
	{
		stack[0].setEnd();
                if(print_flag)
		{
			stringstream ss;
                        print_recursive(stack[0], string(""), ss, tree);
			cout << ss.str();
                        stack.pop_back();
                }
		else
		{
                        print_stack.push_back(stack[0]);
                        stack.pop_back();
                }
	}
	else
	{
		throw runtime_error("error: tried to pop() from empty stack");
	}
}

void TimeNodeStack::print_recursive(const TimeNode& x, const string& arrow,
		stringstream& ss, bool tree)
{
	ss << setw(70) << left << arrow + x.name << setw(24) << left << 
                std::chrono::duration_cast<std::chrono::microseconds>(
		x.getBegin() - start).count() << setw(20) << left << 
		std::chrono::duration_cast<std::chrono::microseconds>(x.getEnd()
				- x.getBegin()).count() << '\n';

	for (TimeNode child : x.children)
	{
		if (arrow.length() == 0 || !tree)
		{
			print_recursive(child, " \\_", ss, tree);
		}
		else
		{
			print_recursive(child, arrow.substr(0, arrow.length() - 2) + 
					"    " + "\\_", ss, tree);
		}
	}
}

string TimeNodeStack::printString(bool tree)
{
	stringstream ss;
        ss << setw(70) << left << "namespace/function name" << setw(24) << 
                left << "unix begin time(μs)" << setw(20) << left <<
		"time elapsed(μs)" <<'\n';
        ss << string(110, '-') << '\n';
	
	for(TimeNode node: print_stack){
	        print_recursive(node, string(""), ss, tree);
        }

	return ss.str();
}

void TimeNodeStack::print() { cout << printString(tree); }

TimeNodeStack t_stack = TimeNodeStack();
