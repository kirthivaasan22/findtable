$restaurants = [
  {
    name: 'Zaitoon',
    address: '35, Woods Road, Royapettah, Chennai',
    location: 'Chennai',
    description: "It's a family restaurant, with variety of biriyani's",
    discount: 30,
    cuisines: ['North Indian', 'Arabian', 'Chinese', 'Kebab', 'Sea food', 'BBQ', 'Biryani'],
    rating: 4.0,
    min_price: 150,
    max_price: 1800,
    tags: ['Sea food', 'BBQ', 'Biriyani', 'North Indian']
  },
  {
    name: 'Thalappakatti',
    address: '38, 1, Velachery Bypass Rd, Velachery, Chennai, Tamil Nadu 600042',
    location: 'Chennai',
    description: "It has taste of traditional biriyani",
    discount: 30,
    cuisines: ['Tamil', 'South Indian', 'North Indian', 'Chinese', 'Biryani', 'Seafood', 'Ice Cream', 'Beverages'],
    rating: 4.2,
    min_price: 150,
    max_price: 1800,
    tags: ['Sea food',  'Biriyani', 'North Indian',  'South Indian']
  },
  {
    name: 'Sangeetha',
    address: '51,150 Feet ByPass Road, Ganapathy Nagar, Velachery, Chennai, Tamil Nadu 600042',
    location: 'Chennai',
    description: "It has taste of traditional biriyani",
    cuisines: ['South Indian', 'North Indian', 'Chinese', 'Fast Food', 'Desserts', 'Beverages', 'Juices'],
    rating: 4.1,
    min_price: 100,
    max_price: 1600,
    tags: ['North Indian', 'Chinese', 'South Indian', 'Beverages', 'Juices']
  },
  {
    name: 'Nambi Vilas',
    address: ' V P Rathinasamy Nadar Rd, Bi Bi Kulam Rd, Indira Nagar, Madurai, Tamil Nadu',
    location: 'Madurai',
    description: "It has taste of traditional biriyani",
    cuisines: ['South Indian', 'Chinese', 'Biryani' ],
    rating: 3.6,
    min_price: 100,
    max_price: 1000,
    tags: ['Chinese', 'South Indian', 'Biriyani']
  },
  {
    name: 'Shree Aishwaryam',
    address: '2-A Lake view, W Main Rd, near Apollo hospital, KK Nagar, Tamil Nadu 625020',
    location: 'Madurai',
    description: "It has taste of traditional biriyani",
    cuisines: ['North Indian', 'South Indian', 'Chinese', 'Street Food', 'Beverages', 'Juices' ],
    rating: 3.7,
    min_price: 70,
    max_price: 1200,
    tags: ['North Indian', 'South Indian', 'Chinese', 'Beverages', 'Juices']
  },
  {
    name: 'Iddly Italy',
    address: "Ram Nagar 3rd St, S S Colony, Near Canara Bank Holiday Home, opp. Street to Raymond's Showroom, Tamil Nadu 625016",
    location: 'Madurai',
    description: "It has taste of traditional biriyani",
    cuisines: ['Italian', 'Fast Food', 'Desserts', 'Pizza'],
    rating: 3.9,
    min_price: 120,
    max_price: 800,
    tags: ['Fast Food', 'Desserts', 'Pizza']
  },
  {
    name: 'Shawar Master',
    address: '175, 83, 2nd Agraharam, near TMS Bus Stop, I Agraharam, Salem, Tamil Nadu 636001',
    location: 'Salem',
    description: "It has taste of traditional biriyani",
    cuisines: ['Beverages', 'Lebanese', 'Rolls', 'Arabian'],
    rating: 4.0,
    min_price: 50,
    max_price: 700,
    tags: ['Beverages', 'Lebanese', 'Rolls']
  },
  {
    name: 'Rasikas Restaurant',
    address: 'Suramangalam Main Rd, Thiruvakavundanur, Salem, Tamil Nadu 636005',
    location: 'Salem',
    description: "It has taste of traditional biriyani",
    cuisines: ['South Indian', 'North Indian', 'Arabian', 'BBQ', 'Continental'],
    rating: 4.3,
    min_price: 200,
    max_price: 1800,
    tags: ['BBQ', 'Continental']
  },
  {
    name: 'Green Park Restaurant',
    address: 'Alagapuram Main Road, Farilands, Alagapuram Pudur, Salem',
    location: 'Salem',
    description: "It has taste of traditional biriyani",
    cuisines: ['North Indian', 'Thai', 'Japanese', 'Continental', 'Chinese'],
    rating: 3.9,
    min_price: 160,
    max_price: 1900,
    tags: ['Continental']
  },
  {
    name: 'Gaurmet Bakes',
    address: 'KaraiCollege Rd, Sekkalai, Karaikudi, Tamil Nadu 630002kudi',
    location: 'Karaikudi',
    description: "It has taste of traditional biriyani",
    cuisines: [ 'Italian'],
    rating: 4.4,
    min_price: 160,
    max_price: 1200,
    tags: ['Bakery', 'Beverages', 'Burger', 'Cafe', 'Desserts', 'Finger Food', 'Ice Cream',]
  },
  {
    name: 'Annapoorna',
    address: '45, koviloore road, Karaikudi, Tamil Nadu 630001',
    location: 'Karaikudi',
    description: "It has taste of traditional biriyani",
    cuisines: ['Tamil', 'South Indian'],
    rating: 4.1,
    min_price: 100,
    max_price: 1100,
    tags: ['South Indian']
  },
  {
    name: 'Aachis Multi Cuisine Restaurant',
    address: 'Mudiyarasan Salai Rd, near Kavitha Nursing Home, Ananda Nagar, Karaikudi, Tamil Nadu 630001',
    location: 'Karaikudi',
    description: "It has taste of traditional biriyani",
    cuisines: ['Chinese', 'North Indian', 'Lebanese'],
    rating: 4.3,
    min_price: 100,
    max_price: 1800,
    tags: ['North Indian', 'Chinese']
  },
  {
    name: 'Behrouz Biryani',
    address: '122/3, Kundhanahalli, Mahadevpura, ITPL Main Road, Whitefield, Bangalore',
    location: 'Bangalore',
    description: "It has taste of traditional biriyani",
    cuisines: ['Biryani', 'North Indian', 'Mughlai', 'Kebab'],
    rating: 4.1,
    min_price: 100,
    max_price: 800,
    tags: ['North Indian', 'Mughlai', 'Kebab', 'Biriyani']
  },
  {
    name: 'Paris Panini',
    address: '2984, 12th Main, HAL 2nd Stage, Indiranagar, Bangalore',
    location: 'Bangalore',
    description: "It has taste of traditional biriyani",
    cuisines: ['Cafe', 'French', 'Desserts', 'Beverages'],
    rating: 4.3,
    min_price: 100,
    max_price: 1000,
    tags: ['Desserts', 'Beverages', 'Cafe']
  },
  {
    name: 'Church Street Social',
    address: '46/1, Cobalt Building, Haridevpur, Shanthala Nagar, Church Street, Bangalore',
    location: 'Bangalore',
    description: "It has taste of traditional biriyani",
    cuisines: ['North Indian', 'Chinese', 'Continental'],
    rating: 4.0,
    min_price: 100,
    max_price: 1500,
    tags: ['Burger', 'Momos', 'Desserts', 'Beverages']
  }
]