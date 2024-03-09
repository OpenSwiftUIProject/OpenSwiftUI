//
//  TransactionHostProvider.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol TransactionHostProvider {
    var mutationHost: GraphHost? { get }
}
