document
  .getElementById("addPersonForm")
  .addEventListener("submit", function (event) {
    event.preventDefault();
    const name = document.getElementById("name").value;
    const age = document.getElementById("age").value;

    fetch("/people", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ name, age }),
    })
      .then((response) => response.json())
      .then((data) => {
        console.log(data);
        fetchPeople(); // Refresh the list after adding
      });
  });

async function fetchPeople() {
  try {
    const response = await fetch("/people", {
      method: "GET",
      headers: {
        Accept: "application/json", // Specifies that the client expects a JSON response
      },
    });
    if (!response.ok) {
      // If the HTTP request status is not 2xx, log the status and throw an error
      throw new Error(`HTTP error! Status: ${response.status}`);
    }
    const data = await response.json(); // Parses the JSON from the response
    console.log("Success fetching people!");
    console.log(data);
    const list = document.getElementById("peopleList");
    list.innerHTML = "";
    

    data.forEach(person => {
      const item = document.createElement('li');    // Create a new <li> element for each person
      const link = document.createElement('a');     // Create a new <a> element
      
      link.href = `/people/${person.id}`;           // Set the href attribute of the <a> element
      link.textContent = person.name;               // Set the text content of the <a> element to the person's name
    
      item.appendChild(link);                       // Append the <a> element to the <li> element
      item.append(` - ${person.age} years old`);    // Append the age text to the <li> element
      
      list.appendChild(item);                       // Append the <li> element to the list
    });
    



    return data; // Returns the parsed JSON data
  } catch (error) {
    console.error("Error fetching people:", error);
    return null; // Optionally return null or handle the error as needed
  }
}

// Initially fetch the list of people
fetchPeople();
