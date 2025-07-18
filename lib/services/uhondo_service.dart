import '../models/uhondo.dart';

class UhondoService {
  static final List<Uhondo> dummyUhondoPosts = [
    Uhondo(
      'Inside the Celebrity World',
      'https://images.unsplash.com/photo-1626808642875-0aa545482dfb?q=80&w=387&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://www.geeksforgeeks.org/springboot/spring-boot-sending-email-via-smtp/',
    ),
    Uhondo(
      'Top 10 Red Carpet Moments',
      'https://images.unsplash.com/photo-1709884735626-63e92727d8b6?q=80&w=928&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://www.geeksforgeeks.org/springboot/spring-boot-sending-email-via-smtp/',
    ),
    Uhondo(
      'Exclusive Interview: Rising Stars',
      'https://plus.unsplash.com/premium_photo-1682091872078-46c5ed6a006d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://www.geeksforgeeks.org/springboot/spring-boot-sending-email-via-smtp/',
    ),
    Uhondo(
      'Fashion Trends in 2025',
      'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e',
      'https://www.geeksforgeeks.org/springboot/spring-boot-sending-email-via-smtp/',
    ),
    Uhondo(
      'Behind the Scenes: Movie Magic',
      'https://plus.unsplash.com/premium_photo-1661889099855-b44dc39e88c9?q=80&w=870&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://www.geeksforgeeks.org/springboot/spring-boot-sending-email-via-smtp/',
    ),
    Uhondo(
      'Inside the Celebrity World',
      'https://images.unsplash.com/photo-1626808642875-0aa545482dfb?q=80&w=387&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://www.geeksforgeeks.org/springboot/spring-boot-sending-email-via-smtp/',
    ),
    Uhondo(
      'Top 10 Red Carpet Moments',
      'https://images.unsplash.com/photo-1709884735626-63e92727d8b6?q=80&w=928&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://www.geeksforgeeks.org/springboot/spring-boot-sending-email-via-smtp/',
    ),
    Uhondo(
      'Exclusive Interview: Rising Stars',
      'https://plus.unsplash.com/premium_photo-1682091872078-46c5ed6a006d?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://www.geeksforgeeks.org/springboot/spring-boot-sending-email-via-smtp/',
    ),
    Uhondo(
      'Fashion Trends in 2025',
      'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e',
      'https://www.geeksforgeeks.org/springboot/spring-boot-sending-email-via-smtp/',
    ),
    Uhondo(
      'Behind the Scenes: Movie Magic',
      'https://images.unsplash.com/photo-1706694442016-bd539e1d102b?q=80&w=477&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://www.geeksforgeeks.org/springboot/spring-boot-sending-email-via-smtp/',
    ),
  ];

  static Future<List<Uhondo>> fetchUhondoPosts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return dummyUhondoPosts;
  }
}
