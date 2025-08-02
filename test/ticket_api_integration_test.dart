import 'package:test/test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('TicketApi Integration Tests', () {
    final sdk = XBoardSDK.instance;
    const String testEmail = 'h89600912@gmail.com';
    const String testPassword = '12345678';
    const String baseUrl = 'https://apiwj0801.wujie001.info';

    setUpAll(() async {
      await sdk.initialize(baseUrl);
      final loginResponse = await sdk.login.login(testEmail, testPassword);
      if (loginResponse.data?.authData != null) {
        sdk.setAuthToken(loginResponse.data!.authData!);
      } else {
        throw Exception('Login failed: ${loginResponse.message}');
      }
    });

    test('fetchTickets should return a list of tickets', () async {
      final response = await sdk.ticket.fetchTickets();
      expect(response.data, isA<List<Ticket>>());
    });

    // Note: createTicket, getTicketDetail, replyTicket, closeTicket tests
    // might require specific setup or cleanup to avoid side effects.
    // They are commented out for now.

    // test('createTicket should create a new ticket', () async {
    //   final response = await sdk.ticket.createTicket(
    //     subject: 'Test Subject',
    //     message: 'Test Message',
    //     level: 0,
    //   );
    //   expect(response.data, isA<Ticket>());
    // });

    // test('getTicketDetail should return ticket details', () async {
    //   // Replace with a valid ticket ID
    //   final ticketId = 123; 
    //   final response = await sdk.ticket.getTicketDetail(ticketId);
    //   expect(response.data, isA<TicketDetail>());
    // });

    // test('replyTicket should reply to a ticket', () async {
    //   // Replace with a valid ticket ID
    //   final ticketId = 123;
    //   final response = await sdk.ticket.replyTicket(
    //     ticketId: ticketId,
    //     message: 'Test Reply',
    //   );
    //   expect(response.data, isNull); // Assuming success returns null data
    // });

    // test('closeTicket should close a ticket', () async {
    //   // Replace with a valid ticket ID
    //   final ticketId = 123;
    //   final response = await sdk.ticket.closeTicket(ticketId);
    //   expect(response.data, isNull); // Assuming success returns null data
    // });
  });
}
