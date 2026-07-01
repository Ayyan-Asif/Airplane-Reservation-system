
#include <iostream>
#include <string>
#include <queue>
#include <vector>
#include <algorithm>
using namespace std;

// ============================================================
//  UTILITY
// ============================================================
void printLine(char c = '-', int n = 60) {
    for (int i = 0; i < n; i++) cout << c;
    cout << "\n";
}

// ============================================================
//  CLASS: Passenger  (OOP - Encapsulation)
// ============================================================
class Passenger{
private:
    int id;
    std::string name;
    std::string contact;
public:
    Passenger* next;

    Passenger(int pid, const std::string& pname, const std::string& pcontact)
    {
     id = pid;
        name = pname;
        contact = pcontact;
        next = NULL;
    }

    int getID() const
    {
        return id;
    }

    std::string getName() const
    {
        return name;
    }

    std::string getContact() const
    {
        return contact;
    }

    void setContact(const std::string& c)
    {
        contact = c;
    }

    void display() const {
        cout << "  ID: " << id << "  Name: " << name << "  Contact: " << contact << "\n";
    }

    // Operator overloading: compare passengers by ID
    bool operator==(const Passenger& other) const {
        return id == other.getID();
    }
};

// ============================================================
//  CLASS: PassengerList  (DSA - Singly Linked List)
// ============================================================
class PassengerList {
private:
    Passenger* head;
    int count;

public:
    PassengerList() : head(	NULL), count(0) {}

    // Add passenger at end
    void addPassenger(Passenger* p) {
        p->next = NULL;
        if (!head) {
            head = p;
        } else {
            Passenger* cur = head;
            while (cur->next) cur = cur->next;
            cur->next = p;
        }
        count++;
    }

    // Remove passenger by ID
    bool removePassenger(int id) {
        if (!head) return false;
        if (head->getID() == id) {
            Passenger* temp = head;
            head = head->next;
            delete temp;
            count--;
            return true;
        }
        Passenger* cur = head;
        while (cur->next && cur->next->getID() != id)
            cur = cur->next;
        if (!cur->next) return false;
        Passenger* temp = cur->next;
        cur->next = temp->next;
        delete temp;
        count--;
        return true;
    }

    // Find passenger by ID
    Passenger* find(int id) {
        Passenger* cur = head;
        while (cur) {
            if (cur->getID() == id) return cur;
            cur = cur->next;
        }
        return NULL;
    }

    // Display all passengers
    void display() const {
        if (!head) { cout << "  (no passengers)\n"; return; }
        Passenger* cur = head;
        while (cur) {
            cur->display();
            cur = cur->next;
        }
    }

    int getCount() const { return count; }
    Passenger* getHead() const { return head; }

    ~PassengerList() {
        Passenger* cur = head;
        while (cur) {
            Passenger* next = cur->next;
            delete cur;
            cur = next;
        }
    }
};

// ============================================================
//  CLASS: SeatNode  (for BST)
// ============================================================
class SeatNode {
public:
    int    seatNumber;
    bool   isBooked;
    int    passengerID;   // -1 if empty
    SeatNode* left;
    SeatNode* right;

    SeatNode(int num)
        : seatNumber(num), isBooked(false),
          passengerID(-1), left(NULL), right(NULL) {}
};

// ============================================================
//  CLASS: SeatBST  (DSA - Binary Search Tree)
// ============================================================
class SeatBST {
private:
    SeatNode* root;

    // Insert helper
    SeatNode* insert(SeatNode* node, int seatNum) {
        if (!node) return new SeatNode(seatNum);
        if (seatNum < node->seatNumber)
            node->left = insert(node->left, seatNum);
        else if (seatNum > node->seatNumber)
            node->right = insert(node->right, seatNum);
        return node;
    }

    // Search helper
    SeatNode* search(SeatNode* node, int seatNum) {
        if (!node || node->seatNumber == seatNum) return node;
        if (seatNum < node->seatNumber) return search(node->left, seatNum);
        return search(node->right, seatNum);
    }

    // In-order traversal (sorted display)
 void inorder(SeatNode* node) const
{
    if (node == NULL)
        return;

    inorder(node->left);

    cout << "  Seat " << node->seatNumber;

    if (node->isBooked)
        cout << "  [BOOKED by PID " << node->passengerID << "]";
    else
        cout << "  [AVAILABLE]";

    cout << endl;

    inorder(node->right);
}

    // Count available seats
    int countAvailable(SeatNode* node) const {
        if (!node) return 0;
        return (!node->isBooked ? 1 : 0)
             + countAvailable(node->left)
             + countAvailable(node->right);
    }

    // Find first available seat
    SeatNode* firstAvailable(SeatNode* node) {
        if (!node) return NULL;
        SeatNode* left = firstAvailable(node->left);
        if (left) return left;
        if (!node->isBooked) return node;
        return firstAvailable(node->right);
    }

    void destroy(SeatNode* node) {
        if (!node) return;
        destroy(node->left);
        destroy(node->right);
        delete node;
    }

public:
    SeatBST() : root(NULL) {}

    void addSeat(int seatNum)       { root = insert(root, seatNum); }
    SeatNode* findSeat(int seatNum) { return search(root, seatNum); }
    void displaySeats() const       { inorder(root); }
    int  availableCount() const     { return countAvailable(root); }
    SeatNode* getFirstAvailable()   { return firstAvailable(root); }

    ~SeatBST() { destroy(root); }
};

// ============================================================
//  CLASS: Flight  (OOP - Encapsulation + Composition)
// ============================================================
class Flight {
public:
    string     flightCode;
    string     origin;
    string     destination;
    string     date;          // "YYYY-MM-DD"
    float      price;
    int        totalSeats;
    SeatBST    seats;         // BST for seat management
    PassengerList passengers; // Linked list of booked passengers
    queue<Passenger*> waitlist; // Queue for waiting passengers

    Flight(string code, string orig, string dest,
           string date, float price, int totalSeats)
        : flightCode(code), origin(orig), destination(dest),
          date(date), price(price), totalSeats(totalSeats) {
        // Populate BST with seat numbers
        for (int i = 1; i <= totalSeats; i++)
            seats.addSeat(i);
    }

    void displayInfo() const {
        cout << "  Flight: " << flightCode
             << "  " << origin << " -> " << destination
             << "  Date: " << date
             << "  Price: $" << price
             << "  Available: " << seats.availableCount()
             << "/" << totalSeats << "\n";
    }
};

// ============================================================
//  CLASS: GraphNode  (for Adjacency List Graph)
// ============================================================
struct RouteEdge {
    string destination;
    float  distance;   // in km
};

struct CityNode {
    string city;
    vector<RouteEdge> routes;
};

// ============================================================
//  CLASS: FlightGraph  (DSA - Graph with Adjacency List)
// ============================================================
class FlightGraph {
private:
    vector<CityNode> cities;

    int findCity(const string& name) {
        for (int i = 0; i < (int)cities.size(); i++)
            if (cities[i].city == name) return i;
        return -1;
    }

public:
    // Add city (node)
    void addCity(const string& name) {
        if (findCity(name) == -1)
            cities.push_back({name, {}});
    }

    // Add route (edge)  bidirectional
    void addRoute(const string& from, const string& to, float dist) {
        addCity(from);
        addCity(to);
        int fi = findCity(from), ti = findCity(to);
        cities[fi].routes.push_back({to, dist});
        cities[ti].routes.push_back({from, dist});
    }

    // Display all routes
   void displayRoutes() const
{
    printLine('=');
    cout << "  FLIGHT ROUTE MAP\n";
    printLine('=');

    for (int i = 0; i < (int)cities.size(); i++)
    {
        cout << "  " << cities[i].city << " connects to:\n";

        for (int j = 0; j < (int)cities[i].routes.size(); j++)
        {
            cout << "    -> "
                 << cities[i].routes[j].destination
                 << "  ("
                 << cities[i].routes[j].distance
                 << " km)\n";
        }
    }
}

bool routeExists(const string& from, const string& to)
{
    int fi = findCity(from);

    if (fi == -1)
        return false;

    for (int i = 0; i < (int)cities[fi].routes.size(); i++)
    {
        if (cities[fi].routes[i].destination == to)
            return true;
    }

    return false;
}
};
// ============================================================
//  CLASS: AirlineSystem  (OOP - Main controller class)
// ============================================================
// ============================================================
//  CLASS: AirlineSystem  (OOP - Main controller class)
// ============================================================

class AirlineSystem
{
private:
    vector<Flight*> flights;
    FlightGraph routeMap;
    int nextPassengerID;

    Flight* findFlight(const string& code)
    {
        for (int i = 0; i < (int)flights.size(); i++)
        {
            if (flights[i]->flightCode == code)
                return flights[i];
        }

        return NULL;
    }

public:
    AirlineSystem()
        : nextPassengerID(1001)
    {
        loadSampleData();
    }

    // -------------------------------------------------------
    //  Load some initial data
    // -------------------------------------------------------
    void loadSampleData() {
        // Add routes to graph
        routeMap.addRoute("Karachi",   "Lahore",    1200);
        routeMap.addRoute("Lahore",    "Islamabad",  290);
        routeMap.addRoute("Islamabad", "Dubai",     2700);
        routeMap.addRoute("Karachi",   "Dubai",     1980);
        routeMap.addRoute("Lahore",    "Dubai",     2850);
        routeMap.addRoute("Dubai",     "London",    5500);

        // Add flights
        flights.push_back(new Flight("PK101", "Karachi",   "Lahore",    "2026-07-10", 120.0f, 5));
        flights.push_back(new Flight("PK202", "Lahore",    "Islamabad", "2026-07-10",  80.0f, 4));
        flights.push_back(new Flight("EK501", "Karachi",   "Dubai",     "2026-07-11", 350.0f, 5));
        flights.push_back(new Flight("EK601", "Dubai",     "London",    "2026-07-12", 700.0f, 4));
        flights.push_back(new Flight("PK305", "Lahore",    "Dubai",     "2026-07-13", 370.0f, 3));
    }

    // -------------------------------------------------------
    //  Display all flights  (DSA - Sorting by date/price)
    // -------------------------------------------------------
   void showAllFlights(bool sortByPrice = false)
{
    vector<Flight*> sorted = flights;

    if (sortByPrice)
    {
        for (int i = 0; i < (int)sorted.size() - 1; i++)
        {
            for (int j = 0; j < (int)sorted.size() - i - 1; j++)
            {
                if (sorted[j]->price > sorted[j + 1]->price)
                {
                    Flight* temp = sorted[j];
                    sorted[j] = sorted[j + 1];
                    sorted[j + 1] = temp;
                }
            }
        }

        cout << "\nAll Flights (sorted by price):\n";
    }
    else
    {
        for (int i = 0; i < (int)sorted.size() - 1; i++)
        {
            for (int j = 0; j < (int)sorted.size() - i - 1; j++)
            {
                if (sorted[j]->date > sorted[j + 1]->date)
                {
                    Flight* temp = sorted[j];
                    sorted[j] = sorted[j + 1];
                    sorted[j + 1] = temp;
                }
            }
        }

        cout << "\nAll Flights (sorted by date):\n";
    }


        printLine();
       for (int i = 0; i < (int)sorted.size(); i++)
{
    sorted[i]->displayInfo();
}
        printLine();
    }

    // -------------------------------------------------------
    //  Search flights by route
    // -------------------------------------------------------
void searchFlights(const string& from, const string& to)
{
    cout << "\n  Flights from " << from << " to " << to << ":\n";
    printLine();

    bool found = false;

    for (int i = 0; i < (int)flights.size(); i++)
    {
        Flight* f = flights[i];

        if (f->origin == from && f->destination == to)
        {
            f->displayInfo();
            found = true;
        }
    }

    if (!found)
        cout << "  No direct flights found.\n";

    printLine();
}

    // -------------------------------------------------------
    //  Book a seat  (uses BST + Linked List + Queue)
    // -------------------------------------------------------
    void bookSeat(const string& flightCode,
                  const string& passengerName,
                  const string& contact,
                  int specificSeat = -1) {

        Flight* f = findFlight(flightCode);
        if (!f) { cout << "  Flight not found!\n"; return; }

        // Create passenger object
        Passenger* p = new Passenger(nextPassengerID++, passengerName, contact);

        // Check seat availability
        if (f->seats.availableCount() == 0) {
            // No seats  add to waitlist queue
            f->waitlist.push(p);
            cout << "  No seats available. "
                 << passengerName << " added to waitlist. "
                 << "Position: " << f->waitlist.size() << "\n";
            return;
        }

        SeatNode* seat = NULL;
        if (specificSeat != -1) {
            seat = f->seats.findSeat(specificSeat);
            if (!seat || seat->isBooked) {
                cout << "  Seat " << specificSeat << " is not available!\n";
                delete p;
                return;
            }
        } else {
            seat = f->seats.getFirstAvailable();
        }

        // Book the seat
        seat->isBooked    = true;
        seat->passengerID = p->getID();
        f->passengers.addPassenger(p);

        cout << "  Booking confirmed!\n";
        cout << "  Passenger ID : " << p->getID() << "\n";
        cout << "  Name         : " << passengerName << "\n";
        cout << "  Flight       : " << flightCode << "\n";
        cout << "  Seat         : " << seat->seatNumber << "\n";
        cout << "  Route        : " << f->origin << " -> " << f->destination << "\n";
        cout << "  Date         : " << f->date << "\n";
        cout << "  Price        : $" << f->price << "\n";
    }

    // -------------------------------------------------------
    //  Cancel booking  (auto-promote from waitlist)
    // -------------------------------------------------------
    void cancelBooking(const string& flightCode, int passengerID) {
        Flight* f = findFlight(flightCode);
        if (!f) { cout << "  Flight not found!\n"; return; }

        // Find which seat the passenger holds (BST inorder scan)
        // We'll search the passenger list first
        Passenger* p = f->passengers.find(passengerID);
        if (!p) { cout << "  Passenger not found on this flight!\n"; return; }

        // Free the seat in BST
        // We need to scan BST  find seat booked by this passenger
        // Using a helper lambda via an in-order scan isn't trivial in BST,
        // so we iterate seat numbers (small range, acceptable)
        bool seatFreed = false;
        for (int s = 1; s <= f->totalSeats; s++) {
            SeatNode* sn = f->seats.findSeat(s);
            if (sn && sn->passengerID == passengerID) {
                sn->isBooked    = false;
                sn->passengerID = -1;
                seatFreed = true;
                cout << "  Seat " << s << " has been freed.\n";
                break;
            }
        }

        // Remove from passenger linked list
        f->passengers.removePassenger(passengerID);
        cout << "  Booking for passenger " << passengerID << " cancelled.\n";

        // Promote from waitlist (Queue - FIFO)
        if (!f->waitlist.empty() && seatFreed) {
            Passenger* next = f->waitlist.front();
            f->waitlist.pop();
            cout << "  Waitlisted passenger " << next->getName()
                 << " (ID:" << next->getID() << ") has been auto-booked!\n";
            // Assign freed seat
            SeatNode* seat = f->seats.getFirstAvailable();
            if (seat) {
                seat->isBooked    = true;
                seat->passengerID = next->getID();
            }
            f->passengers.addPassenger(next);
        }
    }

    // -------------------------------------------------------
    //  View passengers on a flight
    // -------------------------------------------------------
    void viewPassengers(const string& flightCode) {
        Flight* f = findFlight(flightCode);
        if (!f) { cout << "  Flight not found!\n"; return; }

        cout << "\n  Passengers on Flight " << flightCode << ":\n";
        printLine();
        f->passengers.display();
        cout << "  Waitlist size: " << f->waitlist.size() << "\n";
        printLine();
    }

    // -------------------------------------------------------
    //  View seat map  (BST in-order = sorted by seat number)
    // -------------------------------------------------------
    void viewSeats(const string& flightCode) {
        Flight* f = findFlight(flightCode);
        if (!f) { cout << "  Flight not found!\n"; return; }

        cout << "\n  Seat Map for Flight " << flightCode << ":\n";
        printLine();
        f->seats.displaySeats();
        printLine();
    }

    // -------------------------------------------------------
    //  Show route map (Graph)
    // -------------------------------------------------------
    void showRouteMap() {
        routeMap.displayRoutes();
    }

    // -------------------------------------------------------
    //  Add a new flight
    // -------------------------------------------------------
    void addFlight(string code, string orig, string dest,
                   string date, float price, int seats) {
        if (findFlight(code)) {
            cout << "  Flight code already exists!\n"; return;
        }
        flights.push_back(new Flight(code, orig, dest, date, price, seats));
        routeMap.addRoute(orig, dest, 0); // distance unknown, add route
        cout << "  Flight " << code << " added successfully.\n";
    }

    // Destructor  clean up flights
   ~AirlineSystem()
{
    for (int i = 0; i < (int)flights.size(); i++)
    {
        delete flights[i];
    }
}
};

// ============================================================
//  MAIN MENU
// ============================================================
void showMenu() {
    printLine('=');
    cout << "     ?  AIRLINE RESERVATION SYSTEM  ?\n";
    printLine('=');
    cout << "  1. View All Flights (sorted by date)\n";
    cout << "  2. View All Flights (sorted by price)\n";
    cout << "  3. Search Flights by Route\n";
    cout << "  4. Book a Seat\n";
    cout << "  5. Cancel a Booking\n";
    cout << "  6. View Passengers on a Flight\n";
    cout << "  7. View Seat Map\n";
    cout << "  8. View Route Map (Graph)\n";
    cout << "  9. Add New Flight\n";
    cout << "  0. Exit\n";
    printLine('=');
    cout << "  Enter choice: ";
}

int main() {
    AirlineSystem airline;
    int choice;

    while (true) {
        showMenu();
        cin >> choice;
        cin.ignore();
        cout << "\n";

        if (choice == 0) {
            cout << "  Thank you for using Airline System. Goodbye!\n";
            break;
        }

        string code, name, contact, from, to, date;
        float price;
        int seats, pid, seat;

        switch (choice) {

        case 1:
            airline.showAllFlights(false);
            break;

        case 2:
            airline.showAllFlights(true);
            break;

        case 3:
            cout << "  From: "; getline(cin, from);
            cout << "  To  : "; getline(cin, to);
            airline.searchFlights(from, to);
            break;

        case 4:
            cout << "  Flight Code    : "; getline(cin, code);
            cout << "  Passenger Name : "; getline(cin, name);
            cout << "  Contact        : "; getline(cin, contact);
            cout << "  Specific Seat# (0 = auto): "; cin >> seat; cin.ignore();
            airline.bookSeat(code, name, contact, seat == 0 ? -1 : seat);
            break;

        case 5:
            cout << "  Flight Code   : "; getline(cin, code);
            cout << "  Passenger ID  : "; cin >> pid; cin.ignore();
            airline.cancelBooking(code, pid);
            break;

        case 6:
            cout << "  Flight Code: "; getline(cin, code);
            airline.viewPassengers(code);
            break;

        case 7:
            cout << "  Flight Code: "; getline(cin, code);
            airline.viewSeats(code);
            break;

        case 8:
            airline.showRouteMap();
            break;

        case 9:
            cout << "  Flight Code  : "; getline(cin, code);
            cout << "  Origin       : "; getline(cin, from);
            cout << "  Destination  : "; getline(cin, to);
            cout << "  Date (YYYY-MM-DD): "; getline(cin, date);
            cout << "  Price ($)    : "; cin >> price; cin.ignore();
            cout << "  Total Seats  : "; cin >> seats; cin.ignore();
            airline.addFlight(code, from, to, date, price, seats);
            break;

        default:
            cout << "  Invalid option. Try again.\n";
        }

        cout << "\n  Press Enter to continue...";
        cin.ignore();
    }

    return 0;
}
