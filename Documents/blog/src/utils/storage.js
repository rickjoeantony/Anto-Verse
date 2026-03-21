export const getPosts = () => {
  const posts = localStorage.getItem('clubIndustryBlogs');
  return posts ? JSON.parse(posts) : [];
};

export const savePost = (post) => {
  const posts = getPosts();
  const newPost = {
    ...post,
    id: Date.now().toString(),
    createdAt: new Date().toISOString()
  };
  posts.unshift(newPost); // Add to beginning
  localStorage.setItem('clubIndustryBlogs', JSON.stringify(posts));
  return newPost;
};

export const getPostById = (id) => {
  const posts = getPosts();
  return posts.find(p => p.id === id);
};

export const deletePost = (id) => {
  const posts = getPosts();
  const filtered = posts.filter(p => p.id !== id);
  localStorage.setItem('clubIndustryBlogs', JSON.stringify(filtered));
};

// Add initial seed data if empty
export const initializeData = () => {
  if (getPosts().length === 0) {
    const seedPost = {
      title: "Welcome to Club Industry 5.0",
      content: "The future is here. IEEE Computer Society and Jeppiaar Institute of Technology welcome you to the next generation of technological advancement.\n\nIn Industry 5.0, human creativity and robotic precision come together. This blog will explore cyber-physical systems, AI innovations, and sustainable tech.",
      author: "Admin System",
      imageUrl: "https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=2072&auto=format&fit=crop",
      tags: ["Future", "AI", "IEEE"]
    };
    savePost(seedPost);
  }
};
