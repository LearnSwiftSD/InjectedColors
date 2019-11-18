//
//  Combinable.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

#if os(iOS)

import UIKit
import Combine

// MARK: - Combinable Base Code

public struct Assignment<Base> {

    public let baseInstance: Base

    public init(_ base: Base) { self.baseInstance = base }

}

/// The `Combinable` protocol allows conformers to accept values through the means of an `Assignment`. The `Assignment` can be
/// extended to supply various values to the input of the accepting type
public protocol Combinable {

    associatedtype BaseType

    var input: Assignment<BaseType> { get }

}

// MARK: - Custom Subscriptions

/// A custom subscription to capture `UIControl` target events.
public final class UIControlSubscription<S: Subscriber, Control: UIControl>: Subscription where S.Input == Control {

    private var subscriber: S?
    private let control: Control

    init(subscriber: S, control: Control, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        control.addTarget(self, action: #selector(eventOccured), for: event)
    }

    // We do nothing here as we only want to send events when they occur.
    public func request(_ demand: Subscribers.Demand) { }

    public func cancel() { subscriber = nil }

    // We ignore the Subscriber's demand here
    @objc private func eventOccured() { _ = subscriber?.receive(control) }

}

// MARK: - Custom Publishers

/// A custom `Publisher` to work with our custom `UIControlSubscription`.
public struct UIControlPublisher<Control: UIControl>: Publisher {

    public typealias Output = Control
    public typealias Failure = Never

    let control: Control
    let controlEvents: UIControl.Event

    init(control: Control, events: UIControl.Event) {
        self.control = control
        self.controlEvents = events
    }

    public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == UIControlPublisher.Failure, S.Input == UIControlPublisher.Output {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents)
        subscriber.receive(subscription: subscription)
    }
}

// Create our custom operator
extension Publisher where Self.Failure == Never {

    /// Supplies `Publisher.Output` values to a `Combinable` assignments input.
    public func supply(to combinableAssignment: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        return sink(receiveValue: combinableAssignment)
    }

}

// MARK: - UIKit Conformance

extension NSObject: Combinable { }

public extension Combinable where Self: NSObject {

    var input: Assignment<Self> { Assignment(self) }

}

public extension Combinable where Self: UIControl {

    func publisher(for events: UIControl.Event) -> AnyPublisher<Self, Never> {
        return UIControlPublisher(control: self, events: events).eraseToAnyPublisher()
    }

}

// MARK: - Cancellables

/// Handy Dandy alias for `Set<AnyCancellable>` 😁
public typealias Cancellables = Set<AnyCancellable>

public typealias SharedPublisher<Output, Failure: Error> = Publishers.Share<AnyPublisher<Output, Failure>>

#endif
