//
//  OperatorExtension.swift
//  ios_game_test
//
//  Created by Weiheng Ni on 2016-01-19.
//  Copyright © 2016 Weiheng Ni. All rights reserved.
//

import UIKit

// CGPoint
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func + (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x + right.dx, y: left.y + right.dy)
}

func + (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x + right.width, y: left.y + right.height)
}

func * (left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: left * right.x, y: left * right.y)
}

func * (left: CGPoint, right: CGFloat) -> CGPoint {
    return right * left
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

// CGSize
func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

func * (left: CGFloat, right: CGSize) -> CGSize {
    return CGSize(width: left * right.width, height: left * right.height)
}

func * (left: CGSize, right: CGFloat) -> CGSize {
    return right * left
}

func * (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width * right.width, height: left.height * right.height)
}

// CGVector
func + (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
}

func * (left: CGFloat, right: CGVector) -> CGVector {
    return CGVector(dx: left * right.dx, dy: left * right.dy)
}

func * (left: CGVector, right: CGFloat) -> CGVector {
    return right * left
}

func * (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx * right.dx, dy: left.dy * right.dy)
}


func abs (vec: CGVector) -> CGFloat {
    return sqrt(pow(vec.dx, 2) + pow(vec.dy, 2))
}